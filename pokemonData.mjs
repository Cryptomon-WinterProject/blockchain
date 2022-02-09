import dotenv from "dotenv";
import fetch from "node-fetch";
import Web3 from "web3";
import { address, abi } from "./config.mjs";

dotenv.config();
const pokedatabse = [];
const pokemonDb = [];
let damageType = {};
let appData = {};

const { WEB3_PROVIDER, ACCOUNT_PRIVATE_KEY } = process.env;
const web3 = new Web3(WEB3_PROVIDER);

async function load() {
  appData.account = "0xC48E03A9e023b0b12173dAeE8E61e058062BC327";
  appData.contract = new web3.eth.Contract(abi, address);
}

const signTransaction = async (encodedData) => {
  const signedTransaction = await web3.eth.accounts.signTransaction(
    {
      to: address,
      data: encodedData,
      gas: 1000000,
    },
    ACCOUNT_PRIVATE_KEY
  );
  console.log(signedTransaction);
  return signedTransaction;
};

const sendTransaction = async (signedTransaction) => {
  const receipt = await web3.eth.sendSignedTransaction(
    signedTransaction.rawTransaction
  );
  return receipt.status;
};

async function fetchAllPokemon() {
  let allpokemon = await fetch("https://pokeapi.co/api/v2/pokemon?limit=50");
  allpokemon = await allpokemon.json();

  for (let i = 0; i < allpokemon.results.length; i++) {
    let pokemon = allpokemon.results[i];
    await fetchPokemonData(pokemon);
  }
  // console.log(pokemonDb);

  for (let i = 0; i < 18; i += 3) {
    let obj = {
      names: [pokemonDb[i].name, pokemonDb[i + 1].name, pokemonDb[i + 2].name],
      images: [
        pokemonDb[i].image,
        pokemonDb[i + 1].image,
        pokemonDb[i + 2].image,
      ],
      price: Math.floor(Math.random() * 50 + 1),
      monType: pokemonDb[i].type,
      trainingGainPerHour:
        25 -
        Math.floor(Math.random() * (5 - damageType[pokemonDb[i].type].length)),
      // trainingGainPerHour: 15 + Math.floor(Math.random() * 10 + 1),
    };
    pokedatabse.push(obj);
  }

  for (let i = 18; i < 28; i = i + 2) {
    let obj = {
      names: [pokemonDb[i].name, pokemonDb[i + 1].name],
      images: [pokemonDb[i].image, pokemonDb[i + 1].image],
      price: Math.floor(Math.random() * 50 + 1),
      monType: pokemonDb[i].type,
      trainingGainPerHour: 15 + Math.floor(Math.random() * 10 + 1),
    };
    pokedatabse.push(obj);
  }

  for (let i = 34; i < 42; i = i + 2) {
    let obj = {
      names: [pokemonDb[i].name, pokemonDb[i + 1].name],
      images: [pokemonDb[i].image, pokemonDb[i + 1].image],
      price: Math.floor(Math.random() * 50 + 1),
      monType: pokemonDb[i].type,
      trainingGainPerHour: 15 + Math.floor(Math.random() * 10 + 1),
    };
    pokedatabse.push(obj);
  }

  console.log(pokedatabse);
}

async function fetchPokemonData(pokemon) {
  let url = pokemon.url;
  let pokeData = await fetch(url);
  pokeData = await pokeData.json();
  // console.log(pokeData)
  let data = {
    id: pokeData.id,
    name: pokeData.name,
    type: pokeData.types[0].type.name,
    moves: {
      1: pokeData.moves[0].move.name,
      2: pokeData.moves[1].move.name,
      3: pokeData.moves[2].move.name,
      4: pokeData.moves[3].move.name,
    },
    image: `https://img.pokemondb.net/artwork/${pokeData.name}.jpg`,
  };
  pokemonDb.push(data);
}

async function fetchdamage() {
  let type = await fetch(`https://pokeapi.co/api/v2/type/`);
  type = await type.json();

  for (let i = 1; i <= 18; i++) {
    let damage = await fetch(`https://pokeapi.co/api/v2/type/${i}/`);
    damage = await damage.json();
    let obj = {
      type: type.results[i - 1].name,
      advantageAgainst: damage.damage_relations.double_damage_from.map(
        (el) => el.name
      ),
    };

    // damageType.push(obj);
    damageType[obj.type] = obj.advantageAgainst;
  }
  console.log(damageType);
}

const addPokemonData = async () => {
  for (let i = 0; i < pokedatabse.length; i++) {
    const encodedData = appData.contract.methods
      .createMonCollection(
        pokedatabse[i].names,
        pokedatabse[i].images,
        pokedatabse[i].price,
        pokedatabse[i].monType,
        pokedatabse[i].trainingGainPerHour
      )
      .encodeABI();

    const signedTransaction = await signTransaction(encodedData);
    const status = await sendTransaction(signedTransaction);

    console.log("TRANSACTION STATUS : ", status);
  }
};

const main = async () => {
  await fetchdamage();
  await fetchAllPokemon();
  await load();
  await addPokemonData();
};

await main();
