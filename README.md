# GPO
GPO (GPG Password Obfuscator) is a simple Ruby-built CLI that allows a GPG user to store and retrieve passwords from an encrypted file.

### Usage
* First, ensure `settings.yml` is updated with a recipient (this should be you). If `recipient: default`, encryption will be carried out with `--default-recipient-self`.
* Run with `./app.rb [option(s)]`
 	* `-d` or `--decrypt` will simply decrypt the default .gpg file (settings: `encrypted_file`)
 	* `-e` or `--encrypt` will simply encrypt the default .csv file (settings: `decrypted_file`)
 	* `-a` or `--add` will walk you through adding a new entry to your .gpg file (settings: `encrypted_file`)
		* `subject` refers to whatever the password is for (i.e. a website)
		* `username` refers to the username, email, etc. that the password is associated with
		* `password` [self explanatory]
		* `hint` [self-explanatory]
		* `note` refers to any sort of note you may want to attach to the entry
	* `-b` or `--backup` will simply copy your .gpg file to [your file name].gpg.bak (settings: `encrypted_file`)
	* `-f [text]` or `--find [text]` will retrieve the password if given `[text]` matches any `subjects` (i.e. sites)--`[text]` is required

### CSV File Format
`subject,username,password,hint,note`