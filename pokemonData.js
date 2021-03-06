const pokemonDb = [];

async function fetchAllPokemon() {
  let allpokemon = await fetch("https://pokeapi.co/api/v2/pokemon?limit=50");
  allpokemon = await allpokemon.json();

  for (let i = 0; i < allpokemon.results.length; i++) {
    let pokemon = allpokemon.results[i];
    await fetchPokemonData(pokemon);
  }
  // console.log(pokemonDb);

  const pokedatabse = [];
  for (i = 0; i < 18; i = i + 3) {
    let obj = {
      name: [pokemonDb[i].name, pokemonDb[i + 1].name, pokemonDb[i + 2].name],
      image: [
        pokemonDb[i].image,
        pokemonDb[i + 1].image,
        pokemonDb[i + 2].image,
      ],
      id: [pokemonDb[i].id, pokemonDb[i + 1].id, pokemonDb[i + 2].id],
      type: pokemonDb[i].type,
    };
    pokedatabse.push(obj);
  }

  for (i = 18 ; i < 28; i = i + 2) {
    let obj = {
      name: [pokemonDb[i].name, pokemonDb[i + 1].name],
      image: [pokemonDb[i].image, pokemonDb[i + 1].image],
      id: [pokemonDb[i].id, pokemonDb[i + 1].id],
      type: pokemonDb[i].type,
    };
    pokedatabse.push(obj);
  }

   for (i = 34; i < 42; i = i + 2) {
     let obj = {
       name: [pokemonDb[i].name, pokemonDb[i + 1].name],
       image: [pokemonDb[i].image, pokemonDb[i + 1].image],
       id: [pokemonDb[i].id, pokemonDb[i + 1].id],
       type: pokemonDb[i].type,
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

fetchAllPokemon();
