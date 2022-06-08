import type { NextPage } from "next";
import Head from "next/head";
import { Fragment } from "react";
import styles from "../styles/Home.module.css";

const Home: NextPage = () => {
  return (
    <Fragment>
      <Head>
        <title>{`Home | Cryptodevs`}</title>
      </Head>
      <h1>Hello</h1>
    </Fragment>
  );
};

export default Home;
