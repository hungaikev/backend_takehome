const express = require('express');
const { graphqlHTTP } = require('express-graphql');
const { GraphQLObjectType, GraphQLString, GraphQLList, GraphQLSchema, GraphQLBoolean } = require('graphql');
const _ = require('lodash');
const fs = require('fs');

// Load books from resources
const aColorOfHisOwn = JSON.parse(fs.readFileSync('resources/a_color_of_his_own.json', 'utf-8'));
const fishingInTheAir = JSON.parse(fs.readFileSync('resources/fishing_in_the_air.json', 'utf-8'));
const books = [aColorOfHisOwn, fishingInTheAir];

// Create a tokenized structure
const tokenize = (content, tokens) => {
    const output = [];
    let position = 0;
    tokens.forEach(token => {
        const [start, end] = token.position;
        if (start > position) {
            output.push({
                index: null,
                token: null,
                content: content.substring(position, start),
                isTappable: false
            });
        }
        output.push({
            index: tokens.indexOf(token),
            token: token.value,
            content: content.substring(start, end + 1),
            isTappable: true
        });
        position = end + 1;
    });
    if (position < content.length) {
        output.push({
            index: null,
            token: null,
            content: content.substring(position),
            isTappable: false
        });
    }
    return output;
};

const BookType = new GraphQLObjectType({
    name: 'Book',
    fields: {
        id: { type: GraphQLString },
        title: { type: GraphQLString },
        pages: {
            type: new GraphQLList(new GraphQLObjectType({
                name: 'Page',
                fields: {
                    content: {
                        type: new GraphQLList(new GraphQLObjectType({
                            name: 'TokenizedContent',
                            fields: {
                                index: { type: GraphQLString },
                                token: { type: GraphQLString },
                                content: { type: GraphQLString },
                                isTappable: { type: GraphQLBoolean }
                            }
                        })),
                        resolve(parentValue) {
                            return tokenize(parentValue.content, parentValue.tokens);
                        }
                    }
                }
            }))
        }
    }
});

const RootQuery = new GraphQLObjectType({
    name: 'RootQueryType',
    fields: {
        book: {
            type: BookType,
            args: { id: { type: GraphQLString } },
            resolve(parentValue, args) {
                return _.find(books, { id: args.id });
            }
        },
        books: {
            type: new GraphQLList(BookType),
            resolve() {
                return books;
            }
        }
    }
});

const schema = new GraphQLSchema({
    query: RootQuery
});

const app = express();

app.use('/graphql', graphqlHTTP({
    schema,
    graphiql: true
}));

app.listen(4000, () => {
    console.log('Server is running on port 4000..');
});

// At the bottom of your index.js
module.exports = app;
