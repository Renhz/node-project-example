module.exports = {
  "testEnvironment": "node",
  "preset": "ts-jest",
  "moduleNameMapper": {
    "~/(.*)": "<rootDir>/src/$1"
  },
  "transform": {
    "^.+\\.(ts|tsx)$": "ts-jest",
    "^.+\\.(js)$": "babel-jest"
  }
}