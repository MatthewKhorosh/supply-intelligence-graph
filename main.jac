import from byllm.lib { Model, Image }

glob llm = Model(model_name="anthropic/claude-sonnet-4-5-20250929");

# Data types
obj ProductInfo {
    has name: str,
        brand: str,
        category: str,
        quantity: str,
        confidence: str;
}

# Graph nodes
node Restaurant {
    has name: str,
        location: str;
}

node Product {
    has name: str,
        category: str;
}

node Brand {
    has name: str;
}

# Graph edges
edge Uses {}
edge MadeBy {}
edge InCategory {}

# AI identification - one line
"""Identify all supply products visible in a restaurant photo"""
def identify_products(img: Image) -> list[ProductInfo]
    by llm();

# Build graph from photo
with entry {
    img = Image("test_photo.jpg");
    products = identify_products(img);

    rest = Restaurant(name="Test Restaurant", location="Brooklyn");
    root ++> rest;

    for p in products {
        prod = Product(name=p.name, category=p.category);
        brand = Brand(name=p.brand);
        rest ++> prod : Uses;
        prod ++> brand : MadeBy;
    }
}

# Frontend
cl {
    def:pub app() -> JsxElement {
        return <div>
            <h1>Supply Intelligence Graph</h1>
            <p>Upload a photo to build the graph</p>
        </div>;
    }
}
