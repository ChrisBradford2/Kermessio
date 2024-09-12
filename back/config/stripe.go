package config

import (
	"github.com/stripe/stripe-go/v79"
	"os"
)

func InitStripe() {
	// Set your secret key: remember to switch to your live secret key in production!
	// You can find your API keys in the Stripe Dashboard
	stripe.Key = os.Getenv("STRIPE_SECRET_KEY")
}
