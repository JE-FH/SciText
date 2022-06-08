§assign("mail", "bob@example.com")
§assign("mobil", "+4512345678")
§assign("linkedin", "je-fh")
§assign("linkedinurl", "https://www.linkedin.dk/in/")
§assign("github", "je-fh")
§assign("githuburl", "https://github.com/")
§assign("website", "https://jens.ovh")
§assign("shælllink", "https://github.com/Coffee-Hotel-Spa/shaell-interpreter")

§header1(ipsum("10"))

§textbf("Lorem Ipsum") is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Here's a link §href("https://example.com"). The link is formatted using the styling file.

Best regards,

Jens Emil Fink Højriis

§pagebreak()

§usestylepkg("mystylepkg")

§styles.title("Jens Emil Fink Højriis")

§fa("phone") §href("tel:${mobil}", formatphone(mobil, "dk"))
§fa("envelope") §href("mailto:${mail}", mail)
§fa("linkedinsquare") §href(linkedinurl, linkedin)
§fa("github") §href(githuburl, github)
§fa("link") §href(website)

§section("Projects")
