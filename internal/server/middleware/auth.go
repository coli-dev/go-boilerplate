package middleware

import (
	"net/http"
	"strings"

	"github.com/coli-dev/go-boilerplate/internal/server/auth"
	"github.com/coli-dev/go-boilerplate/internal/server/resp"
	"github.com/gin-gonic/gin"
)

const UserIDKey = "user_id"

func Auth() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		if token == "" {
			resp.Error(c, http.StatusBadRequest, resp.ErrBadRequest)
			c.Abort()
			return
		}
		claims, err := auth.VerifyToken(strings.TrimPrefix(token, "Bearer "))
		if err != nil {
			resp.Error(c, http.StatusUnauthorized, resp.ErrUnauthorized)
			c.Abort()
			return
		}
		c.Set(UserIDKey, claims.UserID)
		c.Next()
	}
}

func GetUserID(c *gin.Context) uint {
	if id, exists := c.Get(UserIDKey); exists {
		return id.(uint)
	}
	return 0
}
