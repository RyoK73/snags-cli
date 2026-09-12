import main from "@/cmd/cli.js";

it("main.metaが必須プロパティを持っている", () => {
  expect(main.meta).toHaveProperty("name");
  expect(main.meta).toHaveProperty("version");
  expect(main.meta).toHaveProperty("description");
});
