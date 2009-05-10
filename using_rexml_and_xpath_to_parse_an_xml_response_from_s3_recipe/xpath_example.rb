#!/usr/bin/env ruby

require 'rexml/document'

xml = <<XML
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<book>
  <chapter title="S3's Architecture">
    <section href="s3_architecture/intro.xml"/>
    <section href="s3_architecture/buckets.xml"/>
    <section href="s3_architecture/objects.xml"/>
  	<section href="s3_architecture/acls.xml"/>
  </chapter>
  <chapter title="S3 Recipes">
    <section href="s3_recipes/signing_up_for_s3.xml"/>
    <section href="s3_recipes/installing_ruby_and_awss3gem.xml"/>
    <section href="s3_recipes/setting_up_s3sh.xml"/>
    <section href="s3_recipes/installing_the_firefox_s3_organizer.xml"/>  
    <section href="s3_recipes/dealing_with_multiple_s3_accounts.xml"/>
    <section href="s3_recipes/creating_a_bucket.xml"/>
  </chapter>
  <chapter title="Authenticating S3 Requests">
    <section href="s3_authentication/authenticating_s3_requests.xml"/>
    <section href="s3_authentication/s3_authentication_intro.xml"/>
    <section href="s3_authentication/the_http_verb.xml"/>
    <section 
      href="s3_authentication/the_canonicalized_positional_headers.xml"/>
  </chapter>  
  <appendix>
    <chapter title='Appendix A:S3 Libraries In Other Languages'>
      <section href="appendix/other_languages/python.xml"></section>
      <section href="appendix/other_languages/perl.xml"></section>
      <section href="appendix/other_languages/actionscript.xml"></section>
      <section href="appendix/other_languages/java.xml"></section>
    </chapter>
  </appendix>
</book>
XML

doc = REXML::Document.new(xml).root
chapters = REXML::XPath.match(doc, '//chapter')
puts chapters.join("\n")
