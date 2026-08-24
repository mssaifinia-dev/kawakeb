import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ZARINPAL_MERCHANT_ID = Deno.env.get("ZARINPAL_MERCHANT_ID")!;
const ZARINPAL_SANDBOX = Deno.env.get("ZARINPAL_SANDBOX") === "true";

const API_BASE = ZARINPAL_SANDBOX ? "https://sandbox.zarinpal.com" : "https://api.zarinpal.com";

function htmlPage(title: string, message: string, ok: boolean) {
  return `<!DOCTYPE html>
<html lang="fa" dir="rtl"><head><meta charset="UTF-8"><title>${title}</title>
<style>
body{font-family:Tahoma,sans-serif;background:#0f0620;color:#fff;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center;}
.card{background:rgba(255,255,255,0.06);padding:40px;border-radius:20px;max-width:400px;}
h1{color:${ok ? "#E0A63E" : "#E0507A"};}
</style></head>
<body><div class="card"><h1>${ok ? "✓" : "✕"} ${title}</h1><p>${message}</p></div></body></html>`;
}

Deno.serve(async (req: Request) => {
  try {
    const url = new URL(req.url);
    const authority = url.searchParams.get("Authority");
    const status = url.searchParams.get("Status");

    if (!authority) {
      return new Response(htmlPage("خطا", "اطلاعات پرداخت یافت نشد.", false), {
        headers: { "Content-Type": "text/html; charset=utf-8" },
      });
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

    const { data: payment } = await supabaseAdmin
      .from("payments")
      .select("*")
      .eq("authority", authority)
      .maybeSingle();

    if (!payment) {
      return new Response(htmlPage("خطا", "تراکنش یافت نشد.", false), {
        headers: { "Content-Type": "text/html; charset=utf-8" },
      });
    }

    if (status !== "OK") {
      await supabaseAdmin.from("payments").update({ status: "failed" }).eq("authority", authority);
      return new Response(htmlPage("پرداخت لغو شد", "می‌تونی به اپ برگردی و دوباره تلاش کنی.", false), {
        headers: { "Content-Type": "text/html; charset=utf-8" },
      });
    }

    // از زرین‌پال تایید نهایی می‌گیریم (این مرحله جلوی تقلب رو می‌گیره)
    const verifyRes = await fetch(`${API_BASE}/pg/v4/payment/verify.json`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        merchant_id: ZARINPAL_MERCHANT_ID,
        amount: payment.amount_toman,
        authority,
      }),
    });
    const verifyData = await verifyRes.json();
    const code = verifyData?.data?.code;

    if (code !== 100 && code !== 101) {
      console.error("Zarinpal verify error:", JSON.stringify(verifyData));
      await supabaseAdmin.from("payments").update({ status: "failed" }).eq("authority", authority);
      const reason = verifyData?.errors?.message ? `دلیل: ${verifyData.errors.message}` : "تراکنش تایید نشد.";
      return new Response(htmlPage("پرداخت ناموفق", reason, false), {
        headers: { "Content-Type": "text/html; charset=utf-8" },
      });
    }

    // موفق بود: اشتراک رو خودکار فعال می‌کنیم
    const expiresAt = new Date(Date.now() + payment.duration_days * 24 * 60 * 60 * 1000).toISOString();

    await supabaseAdmin.from("subscriptions").upsert({
      user_id: payment.user_id,
      tier: payment.tier,
      expires_at: expiresAt,
      updated_at: new Date().toISOString(),
    });

    await supabaseAdmin
      .from("payments")
      .update({ status: "paid", ref_id: String(verifyData.data.ref_id ?? "") })
      .eq("authority", authority);

    // اگه این پرداخت با یه اعتبار تخفیف معرفی انجام شده، اون اعتبار رو مصرف‌شده علامت بزن
    if (payment.referral_credit_id) {
      await supabaseAdmin
        .from("referral_credits")
        .update({ redeemed: true })
        .eq("id", payment.referral_credit_id);
    }

    // اگه این کاربر با کد معرف کسی ثبت‌نام کرده بود، حالا که اولین/جدیدترین
    // خریدش موفق شده، برای معرفش یه اعتبار تخفیف تازه می‌سازیم
    try {
      const { data: buyerProfile } = await supabaseAdmin
        .from("profiles")
        .select("referred_by")
        .eq("id", payment.user_id)
        .maybeSingle();

      if (buyerProfile?.referred_by) {
        const { data: settings } = await supabaseAdmin
          .from("referral_settings")
          .select("discount_percent")
          .eq("tier", payment.tier)
          .maybeSingle();

        const discountPercent = settings?.discount_percent ?? 0;
        if (discountPercent > 0) {
          await supabaseAdmin.from("referral_credits").insert({
            referrer_id: buyerProfile.referred_by,
            discount_percent: discountPercent,
            source_tier: payment.tier,
          });
        }
      }
    } catch (refErr) {
      console.error("referral credit grant error:", refErr);
    }

    const tierLabel = payment.tier === "gold" ? "طلایی" : "VIP";
    return new Response(
      htmlPage("پرداخت موفق", `اشتراک ${tierLabel} تو فعال شد. حالا می‌تونی به اپ برگردی.`, true),
      { headers: { "Content-Type": "text/html; charset=utf-8" } },
    );
  } catch (err) {
    console.error("Unexpected zarinpal-verify error:", err);
    return new Response(
      htmlPage("خطا", "مشکلی پیش اومد. با پشتیبانی تماس بگیر یا دوباره تلاش کن.", false),
      { headers: { "Content-Type": "text/html; charset=utf-8" } },
    );
  }
});
