## Introduction

The PDF Generator API is a service that allows you to generate PDF documents by providing input data and selecting a template. 

### Getting Started

The PDF Generator REST APIs is fully containerized application and can be run using docker-compose. To get started with the PDF Generator API, follow these steps:


1. Clone the repository:

    ```bash
    git clone git@github.com:surquest/python-pdf-generator.git
    ```

2. 
2. Install the dependencies:

    ```bash
    npm install
    ```

3. Start the server:

    ```bash
    npm start
    ```

4. The API will be accessible at `http://localhost:3000`.

### Repository Structure

The repository has the following structure:

```
├── config 
│   ├── solution.json               # Solution configuration
│   ├── naming.patterns.json        # Naming patterns for resources used on Google Cloud Platform
│   └── GCP                         # Google Cloud Platform configuration
│       ├── project.env.PROD.json   # GCP project information as id, name, number, region
│       └── service.json            # Collection of configurations for GCP services
├── src                             # Source code of the REST API application
├── iac                             # Infrastructure as Code (terraform scripts)
```

### Deployment

To deploy the PDF Generator API to a production environment, follow these steps:

1. Configure the necessary environment variables.
2. Build the project using the appropriate build command.
3. Deploy the built project to your desired hosting platform.

## Documentation

For detailed documentation on how to use the PDF Generator API, refer to the [API Documentation](https://your-api-documentation-url).

## Support

If you have any questions or need support, please contact our support team at support@example.com.

## License

The PDF Generator API is licensed under the [MIT License](https://opensource.org/licenses/MIT).


https://carbone.io/on-premise.html
https://github.com/carboneio/carbone