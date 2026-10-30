# Pokémon Activity (IT 126 Flutter Assignment)

A Flutter mobile application that fetches and displays live Pokémon data from the official PokéAPI[cite: 7]. The application defaults to **Seviper** on launch and includes a dynamic search function with robust error handling for network connectivity and missing resources.

---

## Features
* **Default Pokémon**: Automatically loads Seviper (`id: 336`) upon startup.
* **Live API Integration**: Asynchronously queries the PokéAPI using `http.get`.
* **Search Bar**: Allows users to search for any Pokémon by name.
* **Error Handling**: Gracefully handles `404 Not Found` responses and network/connection exceptions.
* **Detailed View Cards**: Neatly presents sprite graphics, base experience, height, weight, abilities (with slot and hidden details), and types.

---

## Activity Analysis

1. **What information did the application receive from the Pokémon API, and how was it different from the JSON map used in the previous lesson?**
   - The application received a comprehensive, dynamic JSON object containing real-time Pokémon attributes (such as ID, name, height, weight, nested abilities, types, and sprite URLs) directly from a remote web service[cite: 7]. Unlike a static JSON map embedded locally in the source code, this data is maintained independently of the installed application and can be updated or queried dynamically for any Pokémon[cite: 7].

2. **What role did the HTTP GET method play in retrieving the Pokémon's information?**
   - The HTTP GET method acted as the request verb instructing the server to retrieve and return a representation of the specific Pokémon resource located at the target endpoint URL[cite: 7, 10].

3. **Why did the application need to decode the response body before accessing individual fields?**
   - The raw response body is returned by the server as a plain text string in JSON format. The application needs to decode this text using `jsonDecode` into a Dart `Map<String, dynamic>` so that individual keys and values can be programmatically accessed and mapped to Dart data models[cite: 9].

4. **What was different about the response when the requested Pokémon did not exist? Why should an application check the HTTP status code before processing the response?**
   - When a Pokémon did not exist, the server returned an unsuccessful HTTP status code (specifically **404 Not Found**) rather than a 200 OK success code[cite: 7, 10]. An application must check the status code first because a successful network connection can still complete while reporting a logical failure or error on the server, preventing the app from attempting to parse invalid or missing data[cite: 10].

5. **If the request fails because the device has no internet connection, how should the application respond differently from when the server reports that a Pokémon does not exist?**
   - A network connectivity failure prevents the application from receiving an HTTP response entirely (throwing a socket or connection exception), whereas a 404 response means the server successfully processed the request and explicitly reported that the resource was missing. For no internet connection, the app should prompt the user to check their connection or offer a retry/offline cache, whereas retrying a 404 with the same non-existent name will not solve the issue.

6. **What could the application do to remain useful if the user had previously viewed the Pokémon's information but was now offline?**
   - The application could implement local caching (storing previously fetched JSON payloads locally using device storage) to display the previously viewed Pokémon data even when the device is disconnected, accompanied by a clear notice that the information is loaded from an offline cache.
