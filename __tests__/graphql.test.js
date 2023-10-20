const request = require('supertest');
const app = require('../index');

describe('GraphQL server', () => {
    it('should fetch the content of a book', async () => {
        const query = `
      query {
        book(id: "a_color_of_his_own") {
          title
          pages {
            content {
              content
              token
              isTappable
            }
          }
        }
      }
    `;

        const response = await request(app).post('/graphql').send({ query });

        expect(response.status).toBe(200);
        expect(response.body.data).toHaveProperty('book');
    });
});
