# DynamoDB

Since DynamoDB is fully managed by AWS, there are not many administration tasks to practice locally. The code in this repository lets you run the official DynamoDB image on your machine so you can learn data modelling and interact with the database just as you would if you were running on AWS.

Learn the concepts and come back to practice!
* https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
* https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ql-reference.html
* https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html

Recommended tools:

* [NoSQL Workbench: GUI for data modelling focused on DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.settingup.html)

## Kotlin examples
The sample functions described below were tested on the following AWS SDK version:

```gradle
compile group: 'com.amazonaws', name: 'aws-java-sdk-dynamodb', version: '1.11.929'
```

You will see a few constants in the snippets down below, and this is how they were defined:

```kotlin
const val AWS_REGION = "us-west-1"
const val TABLE_NAME = "dynamodb-table"
const val PARTITION_KEY_NAME = "pk"
const val SORT_KEY_NAME = "sk"
```

### Low level api examples

Creating a DynamoDB client:
```kotlin
val clientBuilder = AmazonDynamoDBClientBuilder.standard()
    .withRegion(AWS_REGION)
//  Uncomment the line below if you want to connect to a DynamoDB container running locally
//  .withEndpointConfiguration(AwsClientBuilder.EndpointConfiguration("http://localhost:8000", AWS_REGION))
    .build()
val client = DynamoDB(clientBuilder)
```

#### Working with tables
---

Listing existent tables on DynamoDB:
```kotlin
val results = client.listTables()
results.forEach {
    println(it.tableName)
}
```

Creating a new table:
```Kotlin
val request = CreateTableRequest()
    .withTableName(TABLE_NAME)
    .withAttributeDefinitions(AttributeDefinition(PARTITION_KEY_NAME, ScalarAttributeType.S))
    // The line below is only necessary if you have a sort key on your design
    .withAttributeDefinitions(AttributeDefinition(SORT_KEY_NAME, ScalarAttributeType.S))
    .withKeySchema(listOf(
        KeySchemaElement(PARTITION_KEY_NAME, KeyType.HASH),
        KeySchemaElement(SORT_KEY_NAME, KeyType.RANGE)
    ))
    .withBillingMode(BillingMode.PAY_PER_REQUEST)
// blocks until aws confirms the creation
client.createTable(request).waitForActive()
```

Deleting a table:
```kotlin
client.getTable(TABLE_NAME).delete()
```


#### Working with items
---

Inserting data:
```kotlin
val item = Item()
    .withPrimaryKey(PARTITION_KEY_NAME, "some value")
    .withString(SORT_KEY_NAME, "some other value")
    // Add whatever attributes you want just like the lines below
    //.withString("some atribute name", "some value")
    //.withNumber("some other atribute name", 123)
client.getTable(TABLE_NAME).putItem(item)
```

Retrieving a item using the exact PK and SK combination:
```kotlin
val item = client.getTable(TABLE_NAME)
    .getItem(PARTITION_KEY_NAME, "pk exact value", SORT_KEY_NAME, "sk exact value")
```

Retrieving all items filtering by partition key only:
```kotlin
val items = client.getTable(TABLE_NAME).query(
    KeyAttribute(PARTITION_KEY_NAME, "pk exact value")
)
```
Retrieving all items filtering by partition key and the beginning of the sort key:
```Kotlin
val items = client.getTable(TABLE_NAME).query(
    KeyAttribute(PARTITION_KEY_NAME, "pk exact value"),
    RangeKeyCondition(SORT_KEY).beginsWith("some sk prefix")
)
```

### DynamoDBMapper examples
For the examples below, consider the following model/entity/item:
```kotlin
@DynamoDBTable(tableName = "people")
data class Person(
    @DynamoDBHashKey(attributeName = "pk")
    @DynamoDBTyped(DynamoDBMapperFieldModel.DynamoDBAttributeType.S)
    var id: UUID = UUID.randomUUID(),

    var name: String = "",

    @DynamoDBTyped(DynamoDBMapperFieldModel.DynamoDBAttributeType.N)
    var age: Number = 0,

    var email: String = "",

    @DynamoDBAttribute(attributeName = "country")
    var currentCountry: String = ""
)
```
Note that the @DynamoDBTyped annotation is necessary for any of the non supported types. [You can see the list of supported types here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBMapper.DataTypes.html).

---

Building the mapper
```kotlin
val client = AmazonDynamoDBClientBuilder.standard()
    .withRegion(AWS_REGION)
    .build()
val mapper = DynamoDBMapper(client)
```

Insertind data:
```kotlin
val person = Person(name = "Person name", age = 40, email = "test@test.test", currentCountry = "Brazil")
mapper.save(person)
```
