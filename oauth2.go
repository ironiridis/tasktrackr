package main

import (
	"fmt"
	"log"
	"io"
	"os"
	"flag"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"github.com/nu7hatch/gouuid"
	
	"github.com/ironiridis/private"
)

func init() {
	
}

func main() {
	var oauthcode = flag.String("code", "", "from Google")
	flag.Parse()
	
	conf := &oauth2.Config{
		ClientID:     private.Get("tasktrackr_gapi_oauth2_clientid"),
		ClientSecret: private.Get("tasktrackr_gapi_oauth2_secret"),
		RedirectURL:  "https://oauth.tasktrackr.net/done",
		Scopes: []string{
			"https://www.googleapis.com/auth/userinfo.email",
		},
		Endpoint: google.Endpoint,
	}
	
	if *oauthcode == "" {
		u4, err := uuid.NewV4()
		if err != nil {
			panic(err)
		}
		url := conf.AuthCodeURL(u4.String())
		fmt.Printf("%v\n", url)
	} else {
	// Handle the exchange code to initiate a transport.
		tok, err := conf.Exchange(oauth2.NoContext, *oauthcode)
		if err != nil {
			log.Fatal(err)
		}
		client := conf.Client(oauth2.NoContext, tok)
		r, err := client.Get("https://www.googleapis.com/oauth2/v2/userinfo?fields=email")
		if err == nil {
			io.Copy(os.Stdout,r.Body)
		}
	}
}

