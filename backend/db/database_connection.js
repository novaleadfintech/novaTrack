import { Database } from "arangojs";
import dotenv from "dotenv";

dotenv.config();
const db = new Database({
  url: process.env.ARANGO_DB_HOST,
  databaseName: process.env.ARANGO_DB_NAME,
  auth: {
    username: process.env.ARANGO_DB_USERNAME,
    password: process.env.ARANGO_DB_PASSWORD,
  },
});

export default db;
