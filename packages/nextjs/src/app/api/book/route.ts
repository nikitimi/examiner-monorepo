import { type NextRequest, NextResponse } from "next/server";
import books from "@/server/bookJSONResolver";

export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const searchParams = url.searchParams;

  const subject = searchParams.get("subject");
  const isSubjectScopeAll = subject === "";

  if (subject === null) {
    return NextResponse.json(
      {
        error: "subject should be present as search params in your request.",
      },
      { status: 400 }
    );
  }
  const selectedBook = books[subject];

  if (!selectedBook && !isSubjectScopeAll) {
    return NextResponse.json(
      {
        error: "subject selected is doesn't exists in the selection.",
      },
      { status: 400 }
    );
  }

  return NextResponse.json(isSubjectScopeAll ? books : selectedBook);
}
