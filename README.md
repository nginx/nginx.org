nginx.org website
=================

This repository hosts the content and static site generator for [nginx.org](https://nginx.org/).

The website is primarily authored in XML and converted to static HTML content through
[Extensible Stylesheet Language Transformations](https://en.wikipedia.org/wiki/XSLT) (XSLT).


Static site generation
----------------------
The [.xslt files](xslt/) in this repo are automatically generated and should not be edited directly.
XML transformation is defined by [.xsls files](xsls/) and performed by [XSLScript](tools/xslscript.pl)
as part of the site generation process.

The XML content is then combined with the corresponding XSLT file(s) that generates HTML in the
**libxslt** directory.

```mermaid
flowchart
    direction LR
    subgraph make
        .xsls -->|XSLScript| .xslt
        subgraph xsltproc
            .xslt --> .html
            .xml ---> .html
        end
    end
 ```

Site generation is performed with [make(1)](GNUmakefile) with several targets, notably:
 * The default target creates the static HTML (this is usually enough for local development).
 * `images` target creates thumbnail icons from [sources](sources/) for the [books page](xml/en/books.xml).
 * `gzip` target creates compressed versions of the HTML and text content which is used by the production website.


Docker image
------------
Use the [Dockerfile](Dockerfile) to create a self-container Docker image that approximates the production website.
```shell
docker build --no-cache -t nginx.org:my_build .
```
The docker image exposes port 8080 as per the convention for container hosting services.


Local development with Docker
-----------------------------
Use [Docker Compose](docker-compose.yml) to enable local development with a text editor (no
other tools required). Site generation is performed within the Docker container whenever a change
is made to the local files in the [css](css/), [xml](xml/), and [xsls](xsls/) directories.

Start the development container:
```
docker compose up --build --watch
```
Test the site by visiting [localhost:8001](http://localhost:8001/).

> **Note:** To keep the site generation time to a minimum, only the core HTML content is produced.
> Use the main [Dockerfile](Dockerfile) for a complete build.


Local development with toolchain
--------------------------------
### Prerequisities
The static site generator uses a UNIX/Linux toolchain that includes:
 * `make`
 * `perl`
 * `xsltproc`
 * `xmllint` - typically found in the **libxml2** or **libxml2-utils** packages
 * `jpegtopnm`, `pamscale` and `pnmtojpeg` - typically found in the **netpbm** package; only required for the `images` make(1) target
 * `rsync` - only required for the `gzip` make(1) target

**macOS** ships with all of the above with the exception of the **netpbm** tools.
This can be installed with [Homebrew](https://formulae.brew.sh/formula/netpbm) if required.

Some **Linux** distros may also require the `perl-dev` or `perl-utils` package.

**Windows** *TODO*

### Building the site content
With the prerequisites installed, run `make` from the top-level directory. This will create the
**libxslt** directory with HTML content therein.

### Running the website locally
Adapt the [docker-nginx.conf](docker-nginx.conf) file to suit your local `nginx` installation.


Authoring content
-----------------
### How pages are constructed
*TODO*

### Making changes
Existing pages are edited by modifying the content in the [xml directory](xml/). After making changes,
run `make` from the top-level directory to regenerate the HTML.

### Creating new pages
New pages should be created in the most appropriate location within a language directory,
typically [xml/en](xml/en/). The [GNUmakefile](xml/en/GNUmakefile) must then be updated to
reference the new page before it is included in the site generation process.

After determining the most appropriate location for the page, choose the most appropriate Document
Type Definition ([DTD](dtd/)) for your content. This will determine the page layout and the XML tags
that are available for markup. The most likely candidates are:

 * [article.dtd](dtd/article.dtd) - for general content
 * [module.dtd](dtd/module.dtd) - for nginx reference documentation

Note that DTD files may include other DTDs, e.g. **article.dtd** [includes](dtd/article.dtd#L18)
[**content.dtd**](dtd/content.dtd).

### Style guide
Pay attention to existing files before making significant edits.
The basic rules for XML content are:

 * Lines are typically no longer than 70 characters, with an absolute maximum of 80 characters.
   `<programlisting>` and `<example>` tags are excluded from this requirement.
 * Each new sentence begins on a new line.
 * A single empty line appears between `<para>` tags and other tags of equal significance.
 * Two empty lines appear between `<section>` tags.
 * Do not link to your content from the menu unless you are creating an all-new type of content.
 * Apply a version bump to the changed file: increment the number by 1 in the `rev=""` line.
 * The commit log criteria:
   * the log line is no longer than 67 characters,
   * the style is similar to existing log entries (see https://hg.nginx.org/nginx.org),
   * the end of a log entry is indicated by a full stop.
   Example: `Improved GNUMakefile explanation.`
 * Review feedback is implemented into the same patch, do not include a separate patch with the review in the PR. The PRs are added as "Rebase and merge" option.
