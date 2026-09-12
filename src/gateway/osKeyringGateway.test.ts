import { getTokenSet } from "@/gateway/osKeyringGateway.js";
import keytar from "keytar";

vi.spyOn(keytar, "getPassword");

describe("getTokenSet", () => {
  const tokenSetEntity = {
    accessToken: "xxxx",
    accessTokenExpiredAt: "xxxx",
    refreshToken: "xxxx",
    refreshTokenExpiredAt: "xxxx",
  };

  it("should return type TokenSet object", async () => {
    vi.mocked(keytar.getPassword).mockResolvedValue(
      JSON.stringify(tokenSetEntity),
    );

    const tokenSet = await getTokenSet();

    expect(tokenSet).toEqual(tokenSetEntity);
  });

  it("should return false when keytar.getPassword returns null", async () => {
    vi.mocked(keytar.getPassword).mockResolvedValue(null);

    const tokenSet = await getTokenSet();

    expect(tokenSet).toBe(false);
  });

  it("should return error obj when stored data is valid", async () => {
    vi.mocked(keytar.getPassword).mockResolvedValue(
      "{}}}}}wrongValue:wrongValue",
    );

    await expect(getTokenSet()).rejects.toThrow();
  });

  it("should return error obj when stored data isn't compatible TokenSet obj", async () => {
    vi.mocked(keytar.getPassword).mockResolvedValue("{egdata:xxxx}");

    await expect(getTokenSet()).rejects.toThrow();
  });
});

afterEach(() => {
  vi.resetAllMocks();
});
