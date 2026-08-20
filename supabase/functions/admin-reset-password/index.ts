// supabase/functions/reset-password/index.ts
//
// چون تایید پیامکی نداریم، برای بازیابی رمز از "نام مادر" (که موقع ثبت‌نام
// گرفته شده) به‌عنوان یک لایه‌ی سبک تایید هویت استفاده می‌کنیم.
// امنیت این روش کامل نیست (هرکسی که نام مادر طرف رو بدونه می‌تونه ریست کنه)
// ولی برای یک اپ سرگرمی با ریسک پایین، معقول است.

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

function normalizePhone(raw: string): string | null {
  const digits = raw.replace(/[^\d+]/g, "");
  const withPlus = digits.startsWith("+") ? digits : "+" + digits;
  if (!/^\+\d{8,15}$/.test(withPlus)) return null;
  return withPlus;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { phone, motherName, newPassword } = await req.json();

    if (!phone || !motherName || !newPassword) {
      return new Response(
        JSON.stringify({ error: "همه‌ی فیلدها الزامی است" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    if (String(newPassword).length < 6) {
      return new Response(
        JSON.stringify({ error: "رمز عبور باید حداقل ۶ کاراکتر باشد" }),
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

    const { data: profile, error: findError } = await supabaseAdmin
      .from("profiles")
      .select("id, mother_name")
      .eq("phone", e164Phone.replace(/^\+/, ""))
      .maybeSingle();

    if (findError || !profile) {
      return new Response(
        JSON.stringify({ error: "حسابی با این شماره پیدا نشد" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const storedMotherName = (profile.mother_name ?? "").trim().toLowerCase();
    const providedMotherName = String(motherName).trim().toLowerCase();

    if (!storedMotherName || storedMotherName !== providedMotherName) {
      return new Response(
        JSON.stringify({ error: "نام مادر مطابقت ندارد" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(profile.id, {
      password: newPassword,
    });

    if (updateError) {
      console.error("updateUserById error:", updateError);
      return new Response(
        JSON.stringify({ error: "خطا در تغییر رمز، دوباره تلاش کنید" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "خطای غیرمنتظره" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
