import bibtexparser


def remove_bib_fields(input_path, output_path, fields_to_remove):
    with open(input_path, "r", encoding="utf-8") as bib_file:
        bib_database = bibtexparser.load(bib_file)

    for entry in bib_database.entries:
        for field in fields_to_remove:
            if field in entry:
                del entry[field]

    with open(output_path, "w", encoding="utf-8") as bib_file:
        bibtexparser.dump(bib_database, bib_file)


# Example usage:
if __name__ == "__main__":
    fields = [
        "annotate",
        "annote",
        "annotation",
        "abstract",
        "date-added",
        "date-modified",
        "bdsk-url-1",
        "bdsk-url-2",
        "bdsk-file-1",
        "bdsk-file-2",
    ]
    remove_bib_fields("./refs/tb.bib", "./refs/out.bib", fields)
