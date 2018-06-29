# jaxpom

When migrating to the releases 9+ of Java, the java.xml.bind module was removed
from the JDK.

In order to continue using this API, you need to explicitly declare
a dependency to the JAXB jars.

This tools tries to automatically append the JAXB dependencies to the pom.xml of the projects using it.

The dependency of a project to JAXB is inferred from its usage of JAXBContext in a java class.

## How it works

1. Find all the Java classes referencing JAXBContext
2. Crawl up the path of each found Java class to find its related project pom.xml
3. Edit the resulting pom.xml list to append the missing JAXB `<dependency>` tags to the project's `<dependencies>`

## Usage

    # At the root of your project
    $ git clone https://github.com/aallrd/jaxpom.git
    $ ln -s jaxpom/jaxpom.sh jaxpom.sh
    $ ./jaxpom.sh
