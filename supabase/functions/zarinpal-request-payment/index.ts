import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const ZARINPAL_MERCHANT_ID = Deno.env.get("ZARINPAL_MERCHANT_ID")!;
const ZARINPAL_SANDBOX = Deno.env.get("ZARINPAL_SANDBOX") === "true";

const API_BASE = ZARINPAL_SANDBOX ? "https://sandbox.zarinpal.com" : "https://api.zarinpal.com";
const STARTPAY_BASE = ZARINPAL_SANDBOX
  ? "https://sandbox.zarinpal.com/pg/StartPay"
  : "https://www.zarinpal.com/pg/StartPay";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const jwt = req.headers.get("Authorization")?.replace("Bearer ", "");
    if (!jwt) {
      return new Response(JSON.stringify({ error: "احراز هویت نشده" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseAsCaller = createClient(SUPABASE_URL, ANON_KEY);
    const { data: callerData } = await supabaseAsCaller.auth.getUser(jwt);
    if (!callerData.user) {
      return new Response(JSON.stringify({ error: "کاربر معتبر نیست" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { tier } = await req.json();
    if (tier !== "gold" && tier !== "vip") {
      return new Response(JSON.stringify({ error: "سطح اشتراک نامعتبر است" }), {
        status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
    const { data: plan } = await supabaseAdmin
      .from("plans")
      .select("price_toman, duration_days")
      .eq("tier", tier)
      .maybeSingle();

    if (!plan || plan.price_toman <= 0) {
      return new Response(JSON.stringify({ error: "قیمت این اشتراک هنوز تنظیم نشده" }), {
        status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // بهترین اعتبار تخفیف معرفی که هنوز استفاده نشده رو پیدا کن (اگه داشت)
    let discountPercent = 0;
    let referralCreditId: string | null = null;
    const { data: credits } = await supabaseAdmin
      .from("referral_credits")
      .select("id, discount_percent")
      .eq("referrer_id", callerData.user.id)
      .eq("redeemed", false)
      .order("discount_percent", { ascending: false })
      .limit(1);

    if (credits && credits.length > 0) {
      discountPercent = credits[0].discount_percent;
      referralCreditId = credits[0].id;
    }

    // این عدد به «تومان» است — همون چیزی که تو دیتابیس (plans) و تو
    // اپ به کاربر نشون داده می‌شه.
    const finalAmountToman = Math.round(plan.price_toman * (1 - discountPercent / 100));

    // ⚠️ زرین‌پال (بدون پارامتر جدا) عدد amount رو «ریال» حساب می‌کنه.
    // چون قیمت‌های ما تو دیتابیس به تومانن، اینجا ضربدر ۱۰ می‌کنیم تا
    // مبلغ واقعی و درست از کاربر گرفته بشه. (پارامتر currency:"IRT"
    // رو امتحان کردیم ولی باعث خطای درگاه شد، پس به روش ریاضی ساده
    // و سازگارتر برگشتیم.)
    const finalAmountRial = finalAmountToman * 10;

    const callbackUrl = `https://kawakeb.ir/payment-callback.html`;
    const tierLabel = tier === "gold" ? "طلایی" : "VIP";

    const zpRes = await fetch(`${API_BASE}/pg/v4/payment/request.json`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        merchant_id: ZARINPAL_MERCHANT_ID,
        amount: finalAmountRial,
        callback_url: callbackUrl,
        description: `خرید اشتراک ${tierLabel} کواکب${discountPercent > 0 ? ` (${discountPercent}% تخفیف معرفی)` : ""}`,
      }),
    });
    const zpData = await zpRes.json();

    if (zpData?.data?.code !== 100) {
      console.error("Zarinpal request error:", zpData);
      return new Response(JSON.stringify({ error: "خطا در اتصال به درگاه پرداخت" }), {
        status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const authority = zpData.data.authority as string;

    // تو دیتابیس همون مبلغ تومان رو ذخیره می‌کنیم (برای نمایش و تاریخچه)،
    // نه مبلغ ریالی — چون amount_toman همه‌جای دیگه‌ی اپ به تومان استفاده می‌شه.
    await supabaseAdmin.from("payments").insert({
      user_id: callerData.user.id,
      tier,
      amount_toman: finalAmountToman,
      duration_days: plan.duration_days,
      authority,
      status: "pending",
      discount_percent: discountPercent,
      referral_credit_id: referralCreditId,
    });

    return new Response(
      JSON.stringify({ paymentUrl: `${STARTPAY_BASE}/${authority}` }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(JSON.stringify({ error: "خطای غیرمنتظره" }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});