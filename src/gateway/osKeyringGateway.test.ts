import {
  getTokenSet,
  setTokenSet,
  deleteTokenSet,
} from "@/gateway/osKeyringGateway.js";
import type { TokenSet } from "@/gateway/osKeyringGateway.types.js";
import keytar from "keytar";

vi.spyOn(keytar, "getPassword");
vi.spyOn(keytar, "setPassword");
vi.spyOn(keytar, "deletePassword");

const tokenSetEntity = {
  accessToken: "xxxx",
  accessTokenExpiredAt: "xxxx",
  refreshToken: "xxxx",
  refreshTokenExpiredAt: "xxxx",
};
describe("getTokenSet", () => {
  it("should return a TokenSet object", async () => {
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

  it("should throw an error when stored data is invalid", async () => {
    vi.mocked(keytar.getPassword).mockResolvedValue(
      "{}}}}}wrongValue:wrongValue",
    );

    await expect(getTokenSet()).rejects.toThrow();
  });

  it("should throw an error when stored data isn't a valid TokenSet object", async () => {
    vi.mocked(keytar.getPassword).mockResolvedValue("{egdata:xxxx}");

    await expect(getTokenSet()).rejects.toThrow();
  });
});

describe("setTokenSet", () => {
  it("should return void", async () => {
    vi.mocked(keytar.setPassword).mockResolvedValue(undefined);

    await expect(setTokenSet(tokenSetEntity)).resolves.toBeUndefined();
  });
  it("should throw an error when the argument isn't a TokenSet object", async () => {
    vi.mocked(keytar.setPassword).mockResolvedValue(undefined);

    const wrongTokenSet = { wrongValue: "invalid" } as unknown as TokenSet;

    await expect(setTokenSet(wrongTokenSet)).rejects.toThrow();
  });

  it("should throw an error when the argument type is any", async () => {
    vi.mocked(keytar.setPassword).mockResolvedValue(undefined);

    const anyTypeArgument = "xx" as any;

    await expect(setTokenSet(anyTypeArgument)).rejects.toThrow();
  });

  it("should throw an error when keytar.setPassword fails", async () => {
    vi.mocked(keytar.setPassword).mockRejectedValue(new Error());

    await expect(setTokenSet(tokenSetEntity)).rejects.toThrow();
  });
});

describe("deleteTokenSet", () => {
  it("should return true", async () => {
    vi.mocked(keytar.deletePassword).mockResolvedValue(true);

    const isDeleted = await deleteTokenSet();

    expect(isDeleted).toBe(true);
  });

  it("should return false when the password hasn't exist yet", async () => {
    vi.mocked(keytar.deletePassword).mockResolvedValue(false);

    const isDeleted = await deleteTokenSet();

    expect(isDeleted).toBe(false);
  });
});

afterEach(() => {
  vi.resetAllMocks();
});
