
# Reads all the .afm files and builds a table of information about them. 
afm_scan_files <- function() {
  message("Scanning afm files in ", metrics_path())
  afmfiles <- normalizePath(list.files(metrics_path(), pattern = "\\.afm$", full.names=TRUE))

  # Build a table of information of all the afm files
  afmdata <- lapply(afmfiles, afm_get_info)
  afmdata <- do.call(rbind, afmdata)

  # The .enc files should have the same base name as the .afm files
  afmdata$encfile <- sub("\\.afm$", ".enc", afmdata$afmfile)
  # Check that each .enc file exists; if not, set to NA
  afmdata$encfile[!file.exists(file.path(metrics_path(), afmdata$encfile))] <- NA

  afmdata
}


# Read in font information from an .afm file
afm_get_info <- function(filename) {
  fd <- file(filename, "r")
  text <- readLines(fd, 30)  # Reading 30 lines should be more than enough
  close(fd)

  # Pull out the font names from lines like this:
  # FamilyName Arial
  # FontName Arial-ItalicMT
  # FullName Arial Italic
  FamilyName <- sub("^FamilyName ", "", text[grepl("^FamilyName", text)])
  FontName   <- sub("^FontName ",   "", text[grepl("^FontName",   text)])
  FullName   <- sub("^FullName ",   "", text[grepl("^FullName",   text)])

  # Read in the Weight field and figure out of it's Bold and/or Italic
  weight <- sub("^Weight ",   "", text[grepl("^Weight",   text)])
  if (grepl("Bold",   weight))  Bold = TRUE
  else                          Bold = FALSE

  if (grepl("Italic", weight))  Italic = TRUE
  else                          Italic = FALSE

  if (grepl("Oblique", weight)) Oblique = TRUE
  else                          Oblique = FALSE

  data.frame(FamilyName, FontName, FullName, afmfile = basename(filename),
             Bold, Italic, Oblique, stringsAsFactors = FALSE)
}
