package op

import (
	"errors"
	"fmt"

	"github.com/coli-dev/go-boilerplate/internal/db"
	"github.com/coli-dev/go-boilerplate/internal/model"
	"gorm.io/gorm"
)

var (
	ErrUserNotFound       = errors.New("user not found")
	ErrEmailAlreadyExists = errors.New("email already exists")
	ErrUserAlreadyExists  = errors.New("username already exists")
	ErrInvalidCredentials = errors.New("invalid credentials")
)

func UserRegister(reg *model.UserRegister) (*model.User, error) {
	var existing model.User
	if err := db.GetDB().Where("email = ?", reg.Email).First(&existing).Error; err == nil {
		return nil, ErrEmailAlreadyExists
	}
	if err := db.GetDB().Where("username = ?", reg.Username).First(&existing).Error; err == nil {
		return nil, ErrUserAlreadyExists
	}

	user := &model.User{
		Username: reg.Username,
		Email:    reg.Email,
		Password: reg.Password,
	}
	if err := user.HashPassword(); err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}
	if err := db.GetDB().Create(user).Error; err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}
	return user, nil
}

func UserLogin(email, password string) (*model.User, error) {
	var user model.User
	if err := db.GetDB().Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, fmt.Errorf("failed to find user: %w", err)
	}
	if err := user.ComparePassword(password); err != nil {
		return nil, ErrInvalidCredentials
	}
	return &user, nil
}

func UserGetByID(id uint) (*model.User, error) {
	var user model.User
	if err := db.GetDB().First(&user, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("failed to find user: %w", err)
	}
	return &user, nil
}

func UserChangePassword(userID uint, oldPassword, newPassword string) error {
	user, err := UserGetByID(userID)
	if err != nil {
		return err
	}
	if err := user.ComparePassword(oldPassword); err != nil {
		return fmt.Errorf("incorrect old password")
	}

	user.Password = newPassword
	if err := user.HashPassword(); err != nil {
		return fmt.Errorf("failed to hash new password: %w", err)
	}

	if err := db.GetDB().Model(user).Update("password", user.Password).Error; err != nil {
		return fmt.Errorf("failed to update password: %w", err)
	}
	return nil
}

func UserChangeUsername(userID uint, newUsername string) error {
	user, err := UserGetByID(userID)
	if err != nil {
		return err
	}
	if user.Username == newUsername {
		return fmt.Errorf("new username is the same as the old username")
	}

	var existing model.User
	if err := db.GetDB().Where("username = ?", newUsername).First(&existing).Error; err == nil {
		return ErrUserAlreadyExists
	}

	if err := db.GetDB().Model(user).Update("username", newUsername).Error; err != nil {
		return fmt.Errorf("failed to update username: %w", err)
	}
	return nil
}
