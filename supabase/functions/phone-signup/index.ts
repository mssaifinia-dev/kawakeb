// supabase/functions/phone-signup/index.ts
//
// ثبت‌نام واقعی با شماره‌موبایل، بدون تایید پیامکی.
// این فانکشن با service role یه حساب واقعی تو Supabase Auth می‌سازه
// و phone_confirm رو مستقیم true می‌ذاره (یعنی از نظر Supabase شماره "تایید شده" حساب می‌شه،
// حتی بدون اینکه واقعاً پیامکی رد و بدل بشه).
//
// بعد از این فانکشن، سمت Flutter باید مستقیماً از supabase.auth.signInWithPassword()
// با همون phone+password استفاده کنه تا Session واقعی بگیره.

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// این‌ها خودکار توسط Supabase تو محیط Edge Function موجودن، نیازی به ست‌کردن دستی نیست
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

function normalizePhone(raw: string): string | null {
  // انتظار داریم Flutter از قبل dial code رو چسبونده باشه (مثلاً +989123456789)
  const digits = raw.replace(/[^\d+]/g, "");
  const withPlus = digits.startsWith("+") ? digits : "+" + digits;
  // باید فقط + و بین ۸ تا ۱۵ رقم باشه (استاندارد E.164)
  if (!/^\+\d{8,15}$/.test(withPlus)) return null;
  return withPlus;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { phone, password, name, birthdate, country, motherName } = await req.json();

    if (!phone || !password) {
      return new Response(
        JSON.stringify({ error: "شماره‌موبایل و رمز الزامی است" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const e164Phone = normalizePhone(phone);
    if (!e164Phone) {
      return new Response(
        JSON.stringify({ error: "فرمت شماره‌موبایل نامعتبر است" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      phone: e164Phone,
      password,
      phone_confirm: true, // شماره رو بدون پیامک "تایید‌شده" علامت می‌زنه
      user_metadata: {
        name: name ?? null,
        birthdate: birthdate ?? null,
        country: country ?? null,
        mother_name: motherName ?? null,
      },
    });

    if (error) {
      // اگه این شماره قبلاً ثبت‌نام کرده
      if (error.message?.toLowerCase().includes("already") || error.status === 422) {
        return new Response(
          JSON.stringify({ error: "این شماره قبلاً ثبت‌نام کرده، وارد شوید", code: "already_exists" }),
          { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      console.error("createUser error:", error);
      return new Response(
        JSON.stringify({ error: "خطا در ساخت حساب، دوباره تلاش کنید" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ success: true, phone: e164Phone, userId: data.user?.id }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "خطای غیرمنتظره" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
