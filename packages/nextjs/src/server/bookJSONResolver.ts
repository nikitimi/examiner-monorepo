"server only";
import fs from "node:fs/promises";
import url from "libs/url";

const booksURL = new URL("../libs/books", url);
const bookDirectories = await fs.readdir(booksURL);
const bookPaths = await Promise.all(
  bookDirectories.map((d) => fs.readdir(new URL(`./books/${d}`, booksURL)))
);
const bookArrayBuffers = await Promise.all(
  bookPaths.map(
    async (a, i) =>
      await Promise.all(
        a.map((f) =>
          fs.readFile(new URL(`./books/${bookDirectories[i]}/${f}`, booksURL))
        )
      )
  )
);
const books: Record<string, Record<string, string | number | boolean>[]> =
  bookArrayBuffers
    .map((a) => a.map((b) => JSON.parse(b.toLocaleString())))
    .reduce(
      (prev, curr, index) => ({ ...prev, [bookDirectories[index]]: curr }),
      {}
    );

export default books;
