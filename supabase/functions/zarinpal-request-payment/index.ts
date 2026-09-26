
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const ZARINPAL_MERCHANT_ID = Deno.env.get("ZARINPAL_MERCHANT_ID")!;
const ZARINPAL_SANDBOX =
  Deno.env.get("ZARINPAL_SANDBOX") === "true";

const API_BASE = ZARINPAL_SANDBOX
  ? "https://sandbox.zarinpal.com"
  : "https://api.zarinpal.com";

const STARTPAY_BASE = ZARINPAL_SANDBOX
  ? "https://sandbox.zarinpal.com/pg/StartPay"
  : "https://www.zarinpal.com/pg/StartPay";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // --------------------------------------------------
    // 1. Authentication
    // --------------------------------------------------

    const jwt = req.headers
      .get("Authorization")
      ?.replace("Bearer ", "");

    if (!jwt) {
      return new Response(
        JSON.stringify({
          error: "احراز هویت نشده",
        }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const supabaseAsCaller = createClient(
      SUPABASE_URL,
      ANON_KEY,
    );

    const { data: callerData, error: callerError } =
      await supabaseAsCaller.auth.getUser(jwt);

    if (callerError || !callerData.user) {
      console.error(
        "Authentication error:",
        callerError,
      );

      return new Response(
        JSON.stringify({
          error: "کاربر معتبر نیست",
        }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // --------------------------------------------------
    // 2. Read tier
    // --------------------------------------------------

    const body = await req.json();
    const tier = body?.tier;

    if (tier !== "gold" && tier !== "vip") {
      return new Response(
        JSON.stringify({
          error: "سطح اشتراک نامعتبر است",
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // --------------------------------------------------
    // 3. Supabase admin
    // --------------------------------------------------

    const supabaseAdmin = createClient(
      SUPABASE_URL,
      SERVICE_ROLE_KEY,
    );

    // --------------------------------------------------
    // 4. Get plan
    // --------------------------------------------------

    const { data: plan, error: planError } =
      await supabaseAdmin
        .from("plans")
        .select("price_toman, duration_days")
        .eq("tier", tier)
        .maybeSingle();

    if (planError) {
      console.error("Plan query error:", planError);

      return new Response(
        JSON.stringify({
          error: "خطا در دریافت اطلاعات اشتراک",
          details: planError.message,
        }),
        {
          status: 500,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    if (!plan || plan.price_toman <= 0) {
      return new Response(
        JSON.stringify({
          error: "قیمت این اشتراک هنوز تنظیم نشده",
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // --------------------------------------------------
    // 5. Referral discount
    // --------------------------------------------------

    let discountPercent = 0;
    let referralCreditId: string | null = null;

    const { data: credits, error: creditsError } =
      await supabaseAdmin
        .from("referral_credits")
        .select("id, discount_percent")
        .eq("referrer_id", callerData.user.id)
        .eq("redeemed", false)
        .order("discount_percent", {
          ascending: false,
        })
        .limit(1);

    if (creditsError) {
      console.error(
        "Referral credits query error:",
        creditsError,
      );
    }

    if (credits && credits.length > 0) {
      discountPercent = credits[0].discount_percent;
      referralCreditId = credits[0].id;
    }

    // --------------------------------------------------
    // 6. Calculate amount
    // --------------------------------------------------

    const finalAmountToman = Math.round(
      plan.price_toman *
        (1 - discountPercent / 100),
    );

    // ZarinPal API amount = Rial
    const finalAmountRial =
      finalAmountToman * 10;

    // --------------------------------------------------
    // 7. Callback
    // --------------------------------------------------

    const callbackUrl =
     "https://kawakeb.ir/payment-callback.html"; 

    const tierLabel =
      tier === "gold"
        ? "طلایی"
        : "VIP";

    // --------------------------------------------------
    // 8. Diagnostic log BEFORE ZarinPal request
    // --------------------------------------------------

    console.log(
      "========== ZARINPAL REQUEST ==========",
    );

    console.log(
      JSON.stringify({
        sandbox: ZARINPAL_SANDBOX,
        api_base: API_BASE,
        request_url:
          `${API_BASE}/pg/v4/payment/request.json`,
        startpay_base: STARTPAY_BASE,

        tier,
        price_toman: plan.price_toman,
        discount_percent: discountPercent,
        final_amount_toman:
          finalAmountToman,
        final_amount_rial:
          finalAmountRial,

        callback_url: callbackUrl,

        merchant_id_exists:
          Boolean(ZARINPAL_MERCHANT_ID),

        merchant_id_length:
          ZARINPAL_MERCHANT_ID?.length ?? 0,
      }),
    );

    console.log(
      "======================================",
    );

    // --------------------------------------------------
    // 9. Send request to ZarinPal
    // --------------------------------------------------

    const zarinpalRequestBody = {
      merchant_id: ZARINPAL_MERCHANT_ID,
      amount: finalAmountRial,
      callback_url: callbackUrl,
      description:
        `خرید اشتراک ${tierLabel}${
          discountPercent > 0
            ? ` (${discountPercent}% تخفیف معرفی)`
            : ""
        }`,
    };

    const zpRes = await fetch(
      `${API_BASE}/pg/v4/payment/request.json`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(
          zarinpalRequestBody,
        ),
      },
    );

    // --------------------------------------------------
    // 10. Read raw response
    // --------------------------------------------------

    const rawResponse =
      await zpRes.text();

    console.log(
      "========== ZARINPAL RESPONSE ==========",
    );

    console.log(
      JSON.stringify({
        http_status: zpRes.status,
        http_ok: zpRes.ok,
        response_body: rawResponse,
      }),
    );

    console.log(
      "========================================",
    );

    let zpData: any;

    try {
      zpData = JSON.parse(rawResponse);
    } catch (parseError) {
      console.error(
        "ZarinPal JSON parse error:",
        parseError,
      );

      return new Response(
        JSON.stringify({
          error:
            "پاسخ زرین‌پال JSON معتبر نیست",
          http_status: zpRes.status,
          raw_response: rawResponse,
        }),
        {
          status: 502,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // --------------------------------------------------
    // 11. Check ZarinPal result
    // --------------------------------------------------

    if (
      !zpData?.data ||
      zpData?.data?.code !== 100 ||
      !zpData?.data?.authority
    ) {
      const zarinpalCode =
        zpData?.errors?.code ??
        zpData?.data?.code ??
        null;

      const zarinpalMessage =
        zpData?.errors?.message ??
        zpData?.data?.message ??
        "خطای نامشخص زرین‌پال";

      console.error(
        "========== ZARINPAL ERROR ==========",
      );

      console.error(
        JSON.stringify({
          http_status: zpRes.status,
          zarinpal_code:
            zarinpalCode,
          zarinpal_message:
            zarinpalMessage,
          full_response:
            zpData,
        }),
      );

      console.error(
        "====================================",
      );

      return new Response(
        JSON.stringify({
          error: "خطای زرین‌پال",

          zarinpal_code:
            zarinpalCode,

          zarinpal_message:
            zarinpalMessage,

          http_status:
            zpRes.status,

          response:
            zpData,
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    // --------------------------------------------------
    // 12. Authority
    // --------------------------------------------------

    const authority =
      zpData.data.authority as string;

    console.log(
      "ZarinPal authority:",
      authority,
    );

    // --------------------------------------------------
    // 13. Save payment
    // --------------------------------------------------

    const { data: insertedPayment, error: paymentError } =
      await supabaseAdmin
        .from("payments")
        .insert({
          user_id:
            callerData.user.id,

          tier,

          amount_toman:
            finalAmountToman,

          duration_days:
            plan.duration_days,

          authority,

          status: "pending",

          discount_percent:
            discountPercent,

          referral_credit_id:
            referralCreditId,
        })
        .select()
        .maybeSingle();

    if (paymentError) {
      console.error(
        "Payment insert error:",
        paymentError,
      );

      return new Response(
        JSON.stringify({
          error:
            "درخواست زرین‌پال ساخته شد اما ذخیره تراکنش در دیتابیس انجام نشد",

          details:
            paymentError.message,

          authority,
        }),
        {
          status: 500,
          headers: {
            ...corsHeaders,
            "Content-Type":
              "application/json",
          },
        },
      );
    }

    console.log(
      "Payment saved:",
      insertedPayment?.id ?? null,
    );

    // --------------------------------------------------
    // 14. Payment URL
    // --------------------------------------------------

    const paymentUrl =
      `${STARTPAY_BASE}/${authority}`;

    console.log(
      "Payment URL:",
      paymentUrl,
    );

    return new Response(
      JSON.stringify({
        success: true,

        paymentUrl,

        authority,

        amount_toman:
          finalAmountToman,

        amount_rial:
          finalAmountRial,

        tier,

        discount_percent:
          discountPercent,

        payment_id:
          insertedPayment?.id ?? null,
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type":
            "application/json",
        },
      },
    );
  } catch (err) {
    console.error(
      "========== UNEXPECTED ERROR ==========",
    );

    console.error(
      err instanceof Error
        ? err.stack
        : err,
    );

    console.error(
      "======================================",
    );

    return new Response(
      JSON.stringify({
        error:
          "خطای غیرمنتظره",

        details:
          err instanceof Error
            ? err.message
            : String(err),
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type":
            "application/json",
        },
      },
    );
  }
});
