# Unofficial Autosar C++ Guidelines Reference

This project has the aim to provide an easier access to the document [1].
Instead of a PDF file, the contents are transferred to a searchable online book
using [mdbook](https://github.com/rust-lang/mdBook).

Due to the automatic generation of this book, please expect wrongly formatted
content, content in the wrong section or even missing content.

The source for this book is available at [2].

## Content Generation

To generate the content of this page, a lot of regex logic is used to extract
the relevant information out of the PDF document [1].

1. Download the document [1] from the official source
2. Convert the document to a `txt` format using e.g. [Cloudconvert](https://cloudconvert.com/)
3. Place the `txt` file in the `script` dicrectory and call `./convert.sh [name].txt`

`convert.sh` uses the following commands to extract and format the content from
the `txt` source:

- `sed`
- `csplit`
- `prettier`

At the end, Markdown files are generated and copied to the `src` folder to be
published by mdbook.

## ToDo

- [ ] Format C++ code blocks automatically
- [ ] Improve regex to close code blocks

## License

This project utilizes the work [1] without any modification for informational
purposes only in accordance with its disclaimer.

The parts of this repository that do not originate from [1] are licensed with
the GPL 3.0 license. Also see [LICENSE](./LICENSE).

[1] [Guidelines for the use of the C++14 language in critical and safety-related systems AUTOSAR AP Release 19-03](https://www.autosar.org/fileadmin/standards/adaptive/22-11/AUTOSAR_RS_CPP14Guidelines.pdf)

[2] [GitHub](https://github.com/sbmueller/autosar_cpp_guidelines)
