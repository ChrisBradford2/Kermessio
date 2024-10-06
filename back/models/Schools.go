package models

type School struct {
	Base
	Name       string     `json:"name" gorm:"not null"`
	Address    string     `json:"address"`
	City       string     `json:"city"`
	PostalCode string     `json:"postal_code"`
	Users      []User     `json:"users" gorm:"foreignKey:SchoolID"`     // Relation avec les utilisateurs
	Kermesses  []Kermesse `json:"kermesses" gorm:"foreignKey:SchoolID"` // Relation avec les kermesses
}
