![svgviewer-output](https://github.com/ElloTechnology/backend_takehome/assets/3518127/561bc8d4-bffc-4360-b9ea-61e876bcec93)



# Backend and DevOps Coding Challenge

👋 Hello,
We are really excited about you potentially joining the team, so we designed this take home exercise to give you a taste of the challenges you may encounter in the role, and better understand what it would be like to work closely together.

Thanks for taking the time, and we hope to talk with you soon!

## About Ello

Ello is a forward-thinking educational technology company dedicated to revolutionizing the way children learn to read. Our mission is to empower young readers with the tools they need to become proficient and passionate readers. We believe that fostering a love for reading is essential for a child's academic and personal growth.

**Note:** Please don't fork this repository or create a pull request against it. Other applicants may take inspiration from it. You should create another repository for the challenge. Once the coding challenge is completed, email your solution to [erin@ello.com](mailto:erin@ello.com).

## Challenge

**Problem Context:** Our app utilizes a speech recognition model capable of analyzing user audio. One challenge we've encountered is ensuring consistent data that the model can recognize. This model can only identify words from the **alphabet dictionary**. For example, if the book text contains the number 100, the model can understand "one hundred" but not "100." To address this issue, we tokenize our books. This approach ensures that we can display text to the child exactly as it appears in the book while also providing words to the model that we can track. It maintains a one-to-one correspondence between the two. In our application, we combine both the original book text and tokenized text, presenting the book text in its original format to the user while passing tokenized text to the model.

The book has a field called `pages`, which is an array of page objects. The page objects contain a field called `content`, which is the page text, and another field called `tokens`, which is an array of tokenized page text.

For example, page content might look like this:

```
"1 The Wonder Ship It is April 10, 1912."
```

and the `tokens` for this `content` looks like this:

```json
[
        {
            "value": "one",
            "position": [
                0,
                1
            ]
        },
        {
            "value": "the",
            "position": [
                2,
                5
            ]
        },
        {
            "value": "wonder",
            "position": [
                6,
                12
            ]
        },
        {
            "value": "ship",
            "position": [
                13,
                17
            ]
        },
        {
            "value": "it",
            "position": [
                18,
                20
            ]
        },
        {
            "value": "is",
            "position": [
                21,
                23
            ]
        },
        {
            "value": "april",
            "position": [
                24,
                29
            ]
        },
        {
            "value": "ten",
            "position": [
                30,
                32
            ]
        },
        {
            "value": "nineteen twelve",
            "position": [
                34,
                38
            ]
        }
   ]
```

To make it easy to display content to the user, we combine the `content` and `token`
for each word in the page to output similar to what we have below.
The `token` is the tokenized word if it exists, otherwise it is null.
The `content` is the original word from the book text. The `isTappable` field is
used to determine if the word should be tappable or not.

```json
[
  {
    "index": 0,
    "token": "one",
    "content": "1",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 1,
    "token": "the",
    "content": "The",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 2,
    "token": "wonder",
    "content": "Wonder",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 3,
    "token": "ship",
    "content": "Ship",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 4,
    "token": "it",
    "content": "It",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 5,
    "token": "is",
    "content": "is",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 6,
    "token": "april",
    "content": "April",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": " "
  },
  {
    "index": 7,
    "token": "ten",
    "content": "10",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "isTappable": false,
    "content": ", "
  },
  {
    "index": 8,
    "token": "nineteen twelve",
    "content": "1912",
    "isTappable": true
  },
  {
    "token": null,
    "index": null,
    "content": ".",
    "isTappable": false
  }
]
```

You will find two books in the `resources` folder. Your challenge will be to create
a simple GraphQL server that when queried will return a book, however content under the
page will no longer be `tokens` and `content` but instead will be the combined `content`
and `token` as shown above.

We have left the overall implementation open, allowing you to use whatever framework or tools you prefer. The only requirement is that the implementation should be either Typescript or Javascript.

### Part 2: DevOps
In the second part of the challenge, your task is to create an Infrastructure as Code (IAC) solution using AWS and Terraform to deploy the application, preferably using AWS Fargate or a similar service. You are encouraged to make use of the AWS free tier for this endeavor. Please strive to adhere to best practices and share your code along with URLs where the applications are deployed.

## You will be evaluated on

- Functional correctness
- Code clarity / structure
- Comments / documentation where necessary
