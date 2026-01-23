package handlers

import (
	"errors"
	"net/http"

	"github.com/coli-dev/go-boilerplate/internal/model"
	"github.com/coli-dev/go-boilerplate/internal/op"
	"github.com/coli-dev/go-boilerplate/internal/server/auth"
	"github.com/coli-dev/go-boilerplate/internal/server/middleware"
	"github.com/coli-dev/go-boilerplate/internal/server/resp"
	"github.com/coli-dev/go-boilerplate/internal/server/router"
	"github.com/gin-gonic/gin"
)

func init() {
	router.NewGroupRouter("/api/v1/user").
		AddRoute(
			router.NewRoute("/login", http.MethodPost).
				Handle(login),
		).
		AddRoute(
			router.NewRoute("/register", http.MethodPost).
				Handle(register),
		)
	router.NewGroupRouter("/api/v1/user").
		Use(middleware.Auth()).
		AddRoute(
			router.NewRoute("/change-password", http.MethodPost).
				Handle(changePassword),
		).
		AddRoute(
			router.NewRoute("/change-username", http.MethodPost).
				Handle(changeUsername),
		)
}

func register(c *gin.Context) {
	var req model.UserRegister
	if err := c.ShouldBindJSON(&req); err != nil {
		resp.Error(c, http.StatusBadRequest, resp.ErrInvalidJSON)
		return
	}
	if req.Username == "" || req.Email == "" || req.Password == "" {
		resp.Error(c, http.StatusBadRequest, resp.ErrBadRequest)
		return
	}
	_, err := op.UserRegister(&req)
	if err != nil {
		if errors.Is(err, op.ErrEmailAlreadyExists) || errors.Is(err, op.ErrUserAlreadyExists) {
			resp.Error(c, http.StatusConflict, err.Error())
			return
		}
		resp.Error(c, http.StatusInternalServerError, resp.ErrDatabase)
		return
	}
	resp.Success(c, "registration successful")
}

func login(c *gin.Context) {
	var req model.UserLogin
	if err := c.ShouldBindJSON(&req); err != nil {
		resp.Error(c, http.StatusBadRequest, resp.ErrInvalidJSON)
		return
	}
	user, err := op.UserLogin(req.Email, req.Password)
	if err != nil {
		if errors.Is(err, op.ErrInvalidCredentials) {
			resp.Error(c, http.StatusUnauthorized, resp.ErrUnauthorized)
			return
		}
		resp.Error(c, http.StatusInternalServerError, resp.ErrInternalServer)
		return
	}
	token, expire, err := auth.GenerateToken(user.ID, req.Expire)
	if err != nil {
		resp.Error(c, http.StatusInternalServerError, resp.ErrInternalServer)
		return
	}
	resp.Success(c, model.UserLoginResponse{Token: token, ExpireAt: expire})
}

func changePassword(c *gin.Context) {
	var req model.UserChangePassword
	if err := c.ShouldBindJSON(&req); err != nil {
		resp.Error(c, http.StatusBadRequest, resp.ErrInvalidJSON)
		return
	}
	userID := middleware.GetUserID(c)
	if err := op.UserChangePassword(userID, req.OldPassword, req.NewPassword); err != nil {
		resp.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	resp.Success(c, "password changed successfully")
}

func changeUsername(c *gin.Context) {
	var req model.UserChangeUsername
	if err := c.ShouldBindJSON(&req); err != nil {
		resp.Error(c, http.StatusBadRequest, resp.ErrInvalidJSON)
		return
	}
	userID := middleware.GetUserID(c)
	if err := op.UserChangeUsername(userID, req.NewUsername); err != nil {
		if errors.Is(err, op.ErrUserAlreadyExists) {
			resp.Error(c, http.StatusConflict, err.Error())
			return
		}
		resp.Error(c, http.StatusBadRequest, err.Error())
		return
	}
	resp.Success(c, "username changed successfully")
}
