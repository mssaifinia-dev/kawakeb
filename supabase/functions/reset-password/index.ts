// supabase/functions/admin-reset-password/index.ts
//
// فقط کاربرانی که تو جدول admins هستن اجازه دارن این فانکشن رو صدا بزنن.
// هویت صدازننده از روی JWT خودش (که Supabase خودکار موقع invoke می‌فرسته) چک می‌شه.

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    const jwt = authHeader?.replace("Bearer ", "");
    if (!jwt) {
      return new Response(
        JSON.stringify({ error: "احراز هویت نشده" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // خود صدازننده رو از روی JWTش شناسایی می‌کنیم
    const supabaseAsCaller = createClient(SUPABASE_URL, ANON_KEY);
    const { data: callerData, error: callerError } = await supabaseAsCaller.auth.getUser(jwt);
    if (callerError || !callerData.user) {
      return new Response(
        JSON.stringify({ error: "کاربر معتبر نیست" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

    // چک می‌کنیم صدازننده واقعاً تو جدول admins هست
    const { data: adminRow } = await supabaseAdmin
      .from("admins")
      .select("user_id")
      .eq("user_id", callerData.user.id)
      .maybeSingle();

    if (!adminRow) {
      return new Response(
        JSON.stringify({ error: "دسترسی نداری" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { userId, newPassword } = await req.json();
    if (!userId || !newPassword) {
      return new Response(
        JSON.stringify({ error: "userId و newPassword الزامی است" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    if (String(newPassword).length < 6) {
      return new Response(
        JSON.stringify({ error: "رمز عبور باید حداقل ۶ کاراکتر باشد" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(userId, {
      password: newPassword,
    });

    if (updateError) {
      console.error("updateUserById error:", updateError);
      return new Response(
        JSON.stringify({ error: "خطا در تغییر رمز" }),
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
