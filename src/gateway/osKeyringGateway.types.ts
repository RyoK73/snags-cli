import { z } from "zod";

const tokenSetSchema = z.object({
  accessToken: z.string(),
  accessTokenExpiredAt: z.string(),
  refreshToken: z.string(),
  refreshTokenExpiredAt: z.string(),
});

type TokenSet = z.infer<typeof tokenSetSchema>;

export { tokenSetSchema, type TokenSet };
