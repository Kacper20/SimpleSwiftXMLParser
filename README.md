## SwiftXMLParser
### Kacper Harasim
#### kacper.harasim@gmail.com


### Description
This project is a simple, recursive-descent XML parser combined with utility to download search results from Google Search API.
It's updated syntactically to Swift 3.2
It's a project I've written on my second year of Bachelor studies, so it has couple of decisions and code paths that are unnecessary from present perspective

### XML Grammar

XML Grammar I've created is rather symplistic one, but handles well common XMLs from the internet.

```
-XML ::= header node*
-header ::= begin_token ? xml <attribute>* ? end_token
-name ::= ciag_znakow_bez_spacji
-string ::= name  | whitespaces |  name whitespaces string
-attribute ::= <name> <equal_sign> >attr_value>
-whitespace ::= //comment: couple of whitespaces in converted into just one.
-equal_sign ::= =
-attr_value ::= " <string> "
-begin_token -> <
-end_token -> >
-close_token -> </
-autoclose_token -> />
-open_end_tag ::=  begin_token name <attribute> <autoclose_token>
-| begin_token name <autoclose_token>
-open_tag ::= <begin_token> <name> <end_token>
-| <begin_token> <name> <attribute> <end_token>
-end_tag ::= <close_token> <name> <end_token>
-node ::= <open_tag> <content> <end_tag>
-| <open_tag> <node> <end_tag>
-| <open_end_tag>
```
