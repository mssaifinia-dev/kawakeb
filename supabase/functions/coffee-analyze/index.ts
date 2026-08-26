import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const MODEL = "@cf/google/gemma-4-26b-a4b-it";

const SYSTEM_PROMPT = `
تو یک فال‌گیر حرفه‌ای قهوه برای اپ «کواکب» هستی.

وظیفه تو فقط این است:
عکس فنجان قهوه را بررسی کن، مهم‌ترین نقش تفاله را پیدا کن و یک تعبیر فارسی جذاب بنویس.

قوانین بسیار مهم:

1. فقط زبان فارسی استفاده کن.
2. انگلیسی ننویس.
3. درباره فرایند فکر کردن یا تحلیل خودت چیزی نگو.
4. reasoning یا توضیح داخلی خودت را نمایش نده.
5. فقط نتیجه نهایی را بنویس.
6. نقش را از روی چیزی که واقعاً در تصویر دیده می‌شود انتخاب کن.
7. اگر نقش کاملاً واضح نیست، نزدیک‌ترین نقش قابل مشاهده را انتخاب کن.
8. تعبیر باید سرگرم‌کننده و امیدوارکننده باشد و هیچ اتفاقی را قطعی اعلام نکند.

فرمت پاسخ دقیقاً باید این باشد:

نقش: [یک یا دو کلمه]

تعبیر: [۴ تا ۶ جمله فارسی]

تعبیر بهتر است به چند جنبه اشاره کند:
- معنی سنتی نقش
- اتفاق یا تغییر احتمالی
- روابط و احساسات در صورت مرتبط بودن
- کار و مسائل مالی در صورت مرتبط بودن
- یک پایان امیدوارکننده

از عبارت‌هایی مثل:
«می‌تواند نشانه...»
«ممکن است...»
«در فال قهوه معمولاً...»
استفاده کن.

اگر تصویر اصلاً فنجان قهوه نیست:

نقش: نامشخص

تعبیر: تصویر فنجان قهوه قابل تشخیص نیست.

فقط همین پاسخ نهایی را بده.
هیچ JSON، Markdown، انگلیسی یا توضیح اضافه‌ای ننویس.
`;

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function cleanPersianResponse(text: string): string {
  let result = text.trim();

  // حذف Markdown احتمالی
  result = result.replace(/```[\s\S]*?```/g, "");

  // اگر مدل قبل از نقش چیزی نوشته باشد
  const roleIndex = result.indexOf("نقش:");

  if (roleIndex !== -1) {
    result = result.substring(roleIndex);
  }

  return result.trim();
}

function parseModelResponse(text: string) {
  const cleaned = cleanPersianResponse(text);

  const symbolMatch = cleaned.match(
    /نقش\s*:\s*([^\n\r]+)/,
  );

  const interpretationMatch = cleaned.match(
    /تعبیر\s*:\s*([\s\S]+)/,
  );

  let symbolName =
    symbolMatch?.[1]?.trim() ?? null;

  let interpretation =
    interpretationMatch?.[1]?.trim() ?? "";

  if (
    symbolName?.toLowerCase() === "نامشخص" ||
    symbolName === "نامشخص"
  ) {
    symbolName = null;
  }

  if (!interpretation) {
    interpretation =
      "تعبیر فنجان آماده نشد. لطفاً دوباره با نور بهتر عکس بگیر.";
  }

  return {
    symbolName,
    interpretation,
  };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  try {
    const body = await req.json();

    let imageBase64 = body?.imageBase64;

    if (
      typeof imageBase64 !== "string" ||
      imageBase64.length < 100
    ) {
      return jsonResponse(
        {
          error: "تصویر معتبر نیست.",
        },
        400,
      );
    }

    const token =
      Deno.env.get("CLOUDFLARE_API_TOKEN");

    const accountId =
      Deno.env.get("CLOUDFLARE_ACCOUNT_ID");

    if (!token || !accountId) {
      return jsonResponse(
        {
          error:
            "تنظیمات Cloudflare کامل نیست.",
        },
        500,
      );
    }

    // حذف data:image/... در صورت وجود
    if (imageBase64.startsWith("data:image")) {
      const commaIndex =
        imageBase64.indexOf(",");

      if (commaIndex !== -1) {
        imageBase64 =
          imageBase64.substring(
            commaIndex + 1,
          );
      }
    }

    console.log(
      `Coffee image received: ${imageBase64.length} base64 chars`,
    );

    const cloudflareUrl =
      `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${MODEL}`;

    const response = await fetch(
      cloudflareUrl,
      {
        method: "POST",

        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },

        body: JSON.stringify({
          messages: [
            {
              role: "system",
              content: SYSTEM_PROMPT,
            },
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text:
                    "فنجان قهوه را بررسی کن و فقط نتیجه نهایی فارسی را بده.",
                },
                {
                  type: "image_url",
                  image_url: {
                    url:
                      `data:image/jpeg;base64,${imageBase64}`,
                  },
                },
              ],
            },
          ],

          /*
           * برای اینکه reasoning بیش از حد طولانی نشود
           * و پاسخ نهایی قطع نشود.
           */
          max_completion_tokens: 1536,

          temperature: 0.3,
        }),
      },
    );

    const responseText =
      await response.text();

    console.log(
      `Cloudflare status: ${response.status}`,
    );

    if (!response.ok) {
      console.error(
        `Cloudflare error: ${responseText}`,
      );

      let errorData: any = null;

      try {
        errorData =
          JSON.parse(responseText);
      } catch (_) {}

      return jsonResponse(
        {
          error:
            errorData?.errors?.[0]?.message ??
            `Cloudflare error ${response.status}`,
        },
        502,
      );
    }

    let data: any;

    try {
      data = JSON.parse(responseText);
    } catch (_) {
      return jsonResponse(
        {
          error:
            "پاسخ Cloudflare قابل خواندن نیست.",
        },
        502,
      );
    }

    const message =
      data?.result?.choices?.[0]?.message;

    /*
     * بسیار مهم:
     *
     * reasoning_content را به کاربر نشان نمی‌دهیم.
     *
     * فقط content مجاز است.
     */
    const content =
      message?.content;

    console.log(
      `Model content length: ${
        typeof content === "string"
          ? content.length
          : 0
      }`,
    );

    if (
      typeof content !== "string" ||
      content.trim().length === 0
    ) {
      return jsonResponse(
        {
          symbolName: null,
          interpretation:
            "مدل نتوانست پاسخ نهایی را آماده کند. لطفاً دوباره با نور بهتر از داخل فنجان عکس بگیر.",
        },
      );
    }

    console.log(
      `Model final content: ${content}`,
    );

    const result =
      parseModelResponse(content);

    return jsonResponse(result);
  } catch (e) {
    console.error(
      "Coffee Analyze Error:",
      e,
    );

    return jsonResponse(
      {
        error:
          e instanceof Error
            ? e.message
            : String(e),
      },
      500,
    );
  }
});