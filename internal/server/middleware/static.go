package middleware

import (
	"embed"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func StaticEmbed(urlPrefix string, embedFS embed.FS) gin.HandlerFunc {
	fs := http.FS(embedFS)
	return static(urlPrefix, fs)
}

func StaticLocal(urlPrefix string, localPath string) gin.HandlerFunc {
	fs := http.Dir(localPath)
	return static(urlPrefix, fs)
}

func static(urlPrefix string, fileSystem http.FileSystem) gin.HandlerFunc {
	fileserver := http.FileServer(fileSystem)
	if urlPrefix != "" {
		fileserver = http.StripPrefix(urlPrefix, fileserver)
	}
	return func(c *gin.Context) {
		if strings.HasPrefix(c.Request.URL.Path, "/api") {
			c.Next()
			return
		}
		if f, err := fileSystem.Open(c.Request.URL.Path); err == nil {
			f.Close()
			c.Header("Cache-Control", "public, max-age=31536000, immutable")
			fileserver.ServeHTTP(c.Writer, c.Request)
			c.Abort()
			return
		}
		if f, err := fileSystem.Open("index.html"); err == nil {
			f.Close()
			c.Request.URL.Path = "/"
			fileserver.ServeHTTP(c.Writer, c.Request)
			c.Abort()
		}
	}
}
