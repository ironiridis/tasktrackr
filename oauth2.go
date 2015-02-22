package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"net/http"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"

	"github.com/ironiridis/private"
	"github.com/nu7hatch/gouuid"
)

type oauthProvider int

const (
	oauthProviderUnknown oauthProvider = iota
	oauthProviderGoogle  oauthProvider = iota
)

func oauthGetConfig(p oauthProvider) *oauth2.Config {
	switch p {
	case oauthProviderGoogle:
		return (&oauth2.Config{
			ClientID:     private.Get("tasktrackr_gapi_oauth2_clientid"),
			ClientSecret: private.Get("tasktrackr_gapi_oauth2_secret"),
			RedirectURL:  "https://oauth.tasktrackr.net/done",
			Scopes: []string{
				"https://www.googleapis.com/auth/userinfo.email",
			},
			Endpoint: google.Endpoint,
		})
	}
	panic("unknown oauth provider passed to oauthGetConfig()")
}

func oauthGetEmailFromGoogle(c *http.Client) string {
	type googleUserInfoResponse struct {
		Email string `json:"email"`
	}

	r, err := c.Get("https://www.googleapis.com/oauth2/v2/userinfo?fields=email")
	if err != nil {
		panic(err)
	}
	dec := json.NewDecoder(r.Body)
	var userinfo googleUserInfoResponse
	err = dec.Decode(&userinfo)
	if err != nil {
		panic(err)
	}
	return userinfo.Email
}

func oauthStart(p oauthProvider) string {
	conf := oauthGetConfig(p)
	u4, err := uuid.NewV4()
	if err != nil {
		panic(err)
	}
	return (conf.AuthCodeURL(u4.String()))
}

func oauthComplete(p oauthProvider, code, state string) string {
	conf := oauthGetConfig(p)
	// TODO need to check "state" and compare with original state value, per spec
	tok, err := conf.Exchange(oauth2.NoContext, code)
	if err != nil {
		panic(err)
	}
	client := conf.Client(oauth2.NoContext, tok)
	switch p {
	case oauthProviderGoogle:
		return oauthGetEmailFromGoogle(client)
	}
	panic("unknown oauth provider passed to oauthComplete()")
}

func main() {
	// This is a silly proof-of-concept using the API Google provides for OAuth.
	//
	var oauthcode = flag.String("code", "", "from Google")
	flag.Parse()

	if *oauthcode == "" {
		fmt.Printf("URL: %s\n", oauthStart(oauthProviderGoogle))
		return
	}

	email := oauthComplete(oauthProviderGoogle, *oauthcode, "")
	fmt.Printf("Email: %s\n", email)
}
