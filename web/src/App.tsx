import { useState } from "react"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Input } from "@/components/ui/input"

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>React + shadcn/ui</CardTitle>
          <CardDescription>Go Boilerplate Client</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex gap-2">
            <Input placeholder="Enter something..." />
            <Button>Submit</Button>
          </div>
          <div className="flex items-center gap-4">
            <Button variant="outline" onClick={() => setCount((c) => c - 1)}>
              -
            </Button>
            <span className="text-lg font-medium">Count: {count}</span>
            <Button variant="outline" onClick={() => setCount((c) => c + 1)}>
              +
            </Button>
          </div>
          <div className="flex gap-2">
            <Button variant="secondary">Secondary</Button>
            <Button variant="destructive">Destructive</Button>
            <Button variant="ghost">Ghost</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

export default App
