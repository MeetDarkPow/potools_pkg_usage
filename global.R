library(potools)

### Extract user-visible messages from a package ###

pkg <- system.file('pkg', package = 'potools')
get_message_data(pkg)
# includes strings provided to the custom R wrapper function catf()
get_message_data(pkg, custom_translation_functions = list(R = "catf:fmt|1"))
# includes untranslated strings provided to the custom
# C/C++ wrapper function ReverseTemplateMessage()
get_message_data(
  pkg,
  custom_translation_functions = list(src = "ReverseTemplateMessage:2")
)
# cleanup
rm(pkg)


### Write a .po or .pot file corresponding to a message database ###

message_data <- get_message_data(system.file('pkg', package='potools'))
desc_data <- read.dcf(system.file('pkg', 'DESCRIPTION', package='potools'), c('Package', 'Version'))
metadata <- po_metadata(
  package = desc_data[, "Package"], version = desc_data[, "Version"],
  language = 'ar_SY', author = 'R User', email = 'ruser@gmail.com',
  bugs = 'https://github.com/ruser/potoolsExample/issues'
)

# add fake translations
message_data[type == "singular", msgstr := "<arabic translation>"]
# Arabic has 6 plural forms
message_data[type == "plural", msgstr_plural := .(as.list(sprintf("<%d translation>", 0:5)))]
# Preview metadata
print(metadata)

# write .po file
write_po_file(
  message_data[message_source == "R"],
  tmp_po <- tempfile(fileext = '.po'),
  metadata
)
writeLines(readLines(tmp_po))

# write .pot template
write_po_file(
  message_data[message_source == "R"],
  tmp_pot <- tempfile(fileext = '.pot'),
  metadata
)
writeLines(readLines(tmp_pot))

# cleanup
file.remove(tmp_po, tmp_pot)
rm(message_data, desc_data, metadata, tmp_po, tmp_pot)
