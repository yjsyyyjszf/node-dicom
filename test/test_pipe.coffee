#! /usr/bin/env coffee
#
# test the dicom decode / json pipeline
fs = require "fs"
zlib = require "zlib"

tags = require "../lib/tags"
decoder = require "../lib/decoder"
json = require "../lib/json"

exports.Dicom2JsonTest =
  "test defined length sequences/items": (test) ->
    test.expect 2
    json.gunzip2json "test/deflate_tests/report.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal 1111, json.get_value(data, tags.ConceptNameCodeSequence, 0, tags.CodeValue)
      test.equal "Consultation Report", json.get_value(data, tags.ConceptNameCodeSequence, 0, tags.CodeMeaning)
      test.done()

  "test undefined length sequences/items": (test) ->
    test.expect 2
    json.gunzip2json "test/report_undef_len.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal 1111, json.get_value(data, tags.ConceptNameCodeSequence, 0, tags.CodeValue)
      test.equal "Consultation Report", json.get_value(data, tags.ConceptNameCodeSequence, 0, tags.CodeMeaning)
      test.done()

  "test implicit vr little endian": (test) ->
    test.expect 2
    json.gunzip2json "test/report_default_ts.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal 1111, json.get_value(data, tags.ConceptNameCodeSequence, 0, tags.CodeValue)
      test.equal "Consultation Report", json.get_value(data, tags.ConceptNameCodeSequence, 0, tags.CodeMeaning)
      test.done()

  "test greek charset (isoir126)": (test) ->
    test.expect 1
    json.gunzip2json "test/charsettests/SCSGREEK.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal "Διονυσιος", json.get_value(data, tags.PatientName).Alphabetic
      test.done()

  "test utf8 charset": (test) ->
    test.expect 2
    json.gunzip2json "test/charsettests/SCSX1.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal "Wang^XiaoDong", json.get_value(data, tags.PatientName).Alphabetic
      test.equal "王^小東", json.get_value(data, tags.PatientName).Ideographic
      test.done()

  "test gb18030 charset": (test) ->
    test.expect 2
    json.gunzip2json "test/charsettests/SCSX2.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal "Wang^XiaoDong", json.get_value(data, tags.PatientName).Alphabetic
      test.equal "王^小东", json.get_value(data, tags.PatientName).Ideographic
      test.done()

  "test quotes in json": (test) ->
    test.expect 1
    json.gunzip2json "test/quotes_jpls.dcm.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.deepEqual {Alphabetic: "\"D'Artagnan\"^asdf"}, json.get_value(data, tags.PatientName)
      test.done()

  "test inlinebinary ob": (test) ->
    test.expect 2
    json.gunzip2json "test/deflate_tests/report.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      elem = json.get_element(data, tags.FileMetaInformationVersion)
      test.ok not elem.Value?
      test.ok elem.InlineBinary
      test.done()


  "test decoding big endian": (test) ->
    test.expect 2
    json.gunzip2json "test/scsarab_be.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      test.equal 512, json.get_value(data, tags.Rows)
      test.equal 512, json.get_value(data, tags.Columns)
      test.done()


  "test decoding implicit vr with undefined length private sequence": (test) ->
    test.expect 4
    json.gunzip2json "test/private_report.gz", (err, data) ->
      if err
        console.log "Error:", err.stack
      elem = tags.for_tag(0x0041A730)
      test.equal 'UN', elem.vr
      priv_cont_sq = json.get_element(data, elem)
      # console.log "priv_cont_sq", priv_cont_sq
      test.ok priv_cont_sq
      test.equal 'SQ', priv_cont_sq.vr
      test.equal 5, priv_cont_sq.Value.length
      test.done()



