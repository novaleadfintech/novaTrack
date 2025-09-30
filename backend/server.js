import dotenv from "dotenv";
import express from "express";
import bodyParser from "body-parser";
import graphqlHttp from "express-graphql";
import http from "http";
import cors from "cors";
import graphqlUploadExpress from "graphql-upload/graphqlUploadExpress.mjs";
import jwt from "jsonwebtoken";
import { applyMiddleware } from "graphql-middleware";
import path from "path";
import { fileURLToPath } from "url";

import graphQlSchema from "./graphql/schema/index.js";
import graphQlResolvers from "./graphql/resolvers/index.js";
import permissions from "./graphql/middleware/permission_middleware.js";
import tachCron from "./utils/tache_cron.js";
 
dotenv.config();

tachCron();

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(bodyParser.raw());
app.use(bodyParser.text());
app.use(graphqlUploadExpress());
app.use(cors());

const getUser = (req) => {
  const token = req.headers.authorization || "";

  if (!token) return null;

  try {
    // Vérifier et décoder le token
    const decoded = jwt.verify(
      token.replace("Bearer ", ""),
      process.env.TOKEN_SECRET_KEY
    );
    return decoded;
  } catch (err) {
    console.error(err);

     return null;
  }
};

// Appliquer les middlewares au schéma
const protectedSchema = applyMiddleware(graphQlSchema, permissions);

app.use(
  "/api/graphql",
  graphqlHttp((req) => {
    return {
      schema: protectedSchema,
      rootValue: graphQlResolvers,
      graphiql: true,
      context: getUser(req),
    };
  })
);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use("/public", express.static(path.join(__dirname, "public")));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ limit: "10mb", extended: true }));

const server = http.createServer(app);
server.keepAliveTimeout = 60 * 1000 + 1000;

server.listen(process.env.SERVER_PORT, () => {
  console.log(
    "🚀 Server is running on " + process.env.SERVER_APP_URL + "/api/graphql"
  );
  console.log("Database is running on " + process.env.ARANGO_DB_HOST);
});
