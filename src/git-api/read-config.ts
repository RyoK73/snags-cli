import fs from "node:fs";
import path from "node:path";
type Config = {
  clientId: string;
};

const getClientId = (): string => {
  const configJson = fs.readFileSync(
    path.join(import.meta.dirname, "../../config.json"),
    "utf-8",
  );
  const data: Config = JSON.parse(configJson);
  if (!("clientId" in data)) throw new Error("Error: clientId not found");
  return data.clientId;
};

export default getClientId;
