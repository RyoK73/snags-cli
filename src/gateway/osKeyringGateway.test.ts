import { getTokenSet, setTokenSet } from "@/gateway/osKeyringGateway.js";
import type { TokenSet } from "@/gateway/osKeyringGateway.types.js";
import keytar from "keytar";

vi.spyOn(keytar, "getPassword");
vi.spyOn(keytar, "setPassword");

const tokenSetEntity = {
  accessToken: "xxxx",
  accessTokenExpiredAt: "xxxx",
  refreshToken: "xxxx",
  refreshTokenExpiredAt: "xxxx",
};
describe("getTokenSet", () => {
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

describe("setTokenSet", () => {
  it("should return void", async () => {
    vi.mocked(keytar.setPassword).mockResolvedValue(undefined);

    await expect(setTokenSet(tokenSetEntity)).resolves.toBeUndefined();
  });
  it("should return error when argument isn't type TokenSet obj", async () => {
    vi.mocked(keytar.setPassword).mockResolvedValue(undefined);

    const wrongTokenSet = { wrongValue: "invalid" } as unknown as TokenSet;

    await expect(setTokenSet(wrongTokenSet)).rejects.toThrow();
  });

  it("should return error when argument type is any", async () => {
    vi.mocked(keytar.setPassword).mockResolvedValue(undefined);

    const anyTypeArgument = "xx" as any;

    await expect(setTokenSet(anyTypeArgument)).rejects.toThrow();
  });

  it("should return error when keytar.setPassword failed", async () => {
    vi.mocked(keytar.setPassword).mockRejectedValue(new Error());

    await expect(setTokenSet(tokenSetEntity)).rejects.toThrow();
  });
});

afterEach(() => {
  vi.resetAllMocks();
});
