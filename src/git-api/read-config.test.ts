// ToDO
// [x] config.jsonのclientIDを返す
// [x] config.jsonが存在しない場合、Errorをthrowする
// [x] clientIdが存在しない場合、"Errorをthrowする
import getClientId from "./read-config.js";
import fs from "node:fs";

it("config.jsonのclientIDを返す", () => {
  const clientId = getClientId();

  expect(clientId).toEqual("Ov23li7QhO1w4RyrAr17");
});

it("config.jsonが存在しない場合、Errorをthrowする", () => {
  vi.spyOn(fs, "readFileSync").mockImplementation(() => {
    throw new Error("Error: ENOENT: no such file or directory");
  });

  expect(() => getClientId()).toThrow(
    "Error: ENOENT: no such file or directory",
  );
});

it("config.jsonにclientIdが存在しない場合、Errorをthrowする", () => {
  vi.spyOn(fs, "readFileSync").mockImplementation(() => '{ "hoge" : "hoge" }');

  expect(() => getClientId()).toThrow("Error: clientId not found");
});

afterEach(() => {
  vi.restoreAllMocks();
});
