task :default => ["document.xml"]

file 'document.xml' => ["document.txt", "document-docinfo.xml", "image_foo.jpg"] do
  sh "a2x -f docbook -v document.txt"
end
