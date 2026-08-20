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

    const callbackUrl = `${SUPABASE_URL}/functions/v1/zarinpal-verify`;
    const tierLabel = tier === "gold" ? "طلایی" : "VIP";

    const zpRes = await fetch(`${API_BASE}/pg/v4/payment/request.json`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        merchant_id: ZARINPAL_MERCHANT_ID,
        amount: plan.price_toman,
        callback_url: callbackUrl,
        description: `خرید اشتراک ${tierLabel} کواکب`,
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

    await supabaseAdmin.from("payments").insert({
      user_id: callerData.user.id,
      tier,
      amount_toman: plan.price_toman,
      duration_days: plan.duration_days,
      authority,
      status: "pending",
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
