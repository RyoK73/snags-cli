import keytar from "keytar";
import {
  tokenSetSchema,
  type TokenSet,
} from "@/gateway/osKeyringGateway.types.js";

const userService = "snags";
const userAccount = "user";

const getTokenSet = async (): Promise<TokenSet | boolean> => {
  const tokenSetString = await keytar.getPassword(userService, userAccount);
  if (!tokenSetString) return false;
  const tokenSet = tokenSetSchema.parse(JSON.parse(tokenSetString));
  return tokenSet;
};

const setTokenSet = async (tokenSet: TokenSet): Promise<void> => {
  tokenSetSchema.parse(tokenSet);
  await keytar.setPassword(userService, userAccount, JSON.stringify(tokenSet));
};

const deleteTokenSet = async (): Promise<boolean> => {
  return keytar.deletePassword(userService, userAccount);
};

export { getTokenSet, setTokenSet, deleteTokenSet };
