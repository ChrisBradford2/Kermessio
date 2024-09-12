package models

type User struct {
	Base
	Username  string `gorm:"unique" json:"username" binding:"required" example:"jdoe"`
	LastName  string `json:"last_name" binding:"required" example:"Doe"`
	FirstName string `json:"first_name" binding:"required" example:"John"`
	Email     string `gorm:"unique" json:"email" binding:"required" example:"john.doe@exmple.com"`
	Password  string `gorm:"not null" json:"password" binding:"required" example:"password"`
	Role      string `json:"role" gorm:"not null" binding:"required" example:"user"`
}

type UserRegister struct {
	Username  string `json:"username" binding:"required" example:"jdoe"`
	LastName  string `json:"last_name" binding:"required" example:"Doe"`
	FirstName string `json:"first_name" binding:"required" example:"John"`
	Email     string `json:"email" binding:"required" example:"john.doe@exmple.com"`
	Password  string `json:"password" binding:"required" example:"password"`
	Role      string `json:"role" binding:"required" example:"user"`
}

type UserRegisterResponse struct {
	Username string `json:"username"`
	Email    string `json:"email"`
}

type UserLogin struct {
	Email    string `json:"email" binding:"required" example:"john.doe@exmple.com"`
	Password string `json:"password" binding:"required" example:"password"`
}

// PublicUser omits sensitive data from user model
type PublicUser struct {
	ID        uint   `json:"id"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Email     string `json:"email"`
}
