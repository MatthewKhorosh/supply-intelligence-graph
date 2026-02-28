import from byllm.lib { Model, Image }

glob llm = Model(model_name="anthropic/claude-sonnet-4-5-20250929");

obj ProductInfo {
    has name: str,
        brand: str,
        category: str;
}

"""Identify all restaurant supply products visible in this photo"""
def identify_products(img: Image) -> list[ProductInfo]
    by llm();

walker :pub IdentifyProducts {
    can identify with Root entry {
        img = Image("test_photo.jpg");
        products = identify_products(img);
        results = [];
        count = len(products);
        spacing = 600 / (count + 1);
        i = 0;
        for p in products {
            i = i + 1;
            x_pos = int(spacing * i + 100);
            results.append({
                "name": p.name,
                "brand": p.brand,
                "category": p.category,
                "x": x_pos,
                "y": 400
            });
        }
        report results;
    }
}

with entry { }

cl {
    def:pub app() -> JsxElement {
        has products: list = [];
        has loading: bool = False;

        async def runAnalysis() -> None {
            loading = True;
            response = await fetch("/walker/IdentifyProducts", {"method": "POST", "headers": {"Content-Type": "application/json"}});
            data = await response.json();
            products = data["data"]["reports"][0] if data["data"]["reports"] else [];
            loading = False;
        }

        can with entry { runAnalysis(); }

        return <div style={{"background": "#0a0a0a", "minHeight": "100vh", "fontFamily": "system-ui", "padding": "20px", "color": "white"}}>
            <div style={{"textAlign": "center", "marginBottom": "8px"}}>
                <h1 style={{"fontSize": "1.5rem", "fontWeight": "700", "margin": "0", "letterSpacing": "-0.02em"}}>Supply Intelligence Graph</h1>
                <p style={{"color": "#555", "fontSize": "0.65rem", "letterSpacing": "0.12em", "margin": "4px 0 0 0"}}>AGENTIC AI FOR FOODSERVICE DISTRIBUTION</p>
            </div>
            <div style={{"textAlign": "center", "marginBottom": "16px"}}>
                <button
                    onClick={lambda e: any -> None {
                        async def doAnalyze() -> None {
                            runAnalysis();
                        }
                        doAnalyze();
                    }}
                    style={{"background": "#8b5cf6", "color": "white", "border": "none", "padding": "10px 28px", "borderRadius": "8px", "fontSize": "13px", "cursor": "pointer", "fontWeight": "600"}}
                >{("⏳ Analyzing...") if loading else ("🔍 Analyze Restaurant Photo")}</button>
            </div>
            <div style={{"display": "flex", "gap": "12px", "justifyContent": "center", "marginBottom": "12px", "flexWrap": "wrap"}}>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#10b981"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>INPUT</span></div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#06b6d4"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>SCRAPE</span></div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#8b5cf6"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>VISION AI</span></div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#4ECDC4"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>PRODUCTS</span></div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#f59e0b"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>ENRICH</span></div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#FF6B6B"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>RESTAURANT</span></div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "7px", "height": "7px", "borderRadius": "50%", "background": "#ec4899"}}></div><span style={{"color": "#444", "fontSize": "0.55rem"}}>TRAINING</span></div>
            </div>
            <svg viewBox="0 0 800 750" style={{"width": "100%", "maxWidth": "800px", "margin": "0 auto", "display": "block"}}>

                <line x1="400" y1="55" x2="180" y2="145" stroke="#10b98133" strokeWidth="1.5"></line>
                <line x1="400" y1="55" x2="400" y2="145" stroke="#10b98133" strokeWidth="1.5"></line>
                <line x1="400" y1="55" x2="620" y2="145" stroke="#10b98133" strokeWidth="1.5"></line>
                <line x1="180" y1="145" x2="400" y2="270" stroke="#06b6d433" strokeWidth="1"></line>
                <line x1="400" y1="145" x2="400" y2="270" stroke="#ef444433" strokeWidth="1"></line>
                <line x1="620" y1="145" x2="400" y2="270" stroke="#f59e0b33" strokeWidth="1"></line>

                {[<line x1="400" y1="300" x2={p["x"]} y2="378" stroke="#8b5cf644" strokeWidth="1"></line> for p in products]}
                {[<line x1={p["x"]} y1="422" x2="400" y2="518" stroke="#FF6B6B33" strokeWidth="1"></line> for p in products]}

                <line x1="400" y1="540" x2="220" y2="630" stroke="#f59e0b33" strokeWidth="1"></line>
                <line x1="400" y1="540" x2="580" y2="630" stroke="#06b6d433" strokeWidth="1"></line>
                <line x1="220" y1="630" x2="400" y2="710" stroke="#10b98133" strokeWidth="1"></line>
                <line x1="580" y1="630" x2="400" y2="710" stroke="#10b98133" strokeWidth="1"></line>
                <line x1="400" y1="710" x2="80" y2="270" stroke="#ec489922" strokeWidth="1" strokeDasharray="4 4"></line>
                <line x1="80" y1="270" x2="720" y2="270" stroke="#ec489922" strokeWidth="1" strokeDasharray="4 4"></line>

                <circle cx="400" cy="55" r="28" fill="#111" stroke="#10b981" strokeWidth="1.5"></circle>
                <text x="400" y="52" textAnchor="middle" fill="white" fontSize="10" fontWeight="500">ZIP + Cuisine</text>
                <text x="400" y="64" textAnchor="middle" fill="#10b981" fontSize="7">Data Source</text>

                <circle cx="180" cy="145" r="22" fill="#111" stroke="#06b6d4" strokeWidth="1.5"></circle>
                <text x="180" y="142" textAnchor="middle" fill="white" fontSize="9">Google Places</text>
                <text x="180" y="154" textAnchor="middle" fill="#06b6d4" fontSize="7">174 restaurants</text>

                <circle cx="400" cy="145" r="20" fill="#111" stroke="#ef4444" strokeWidth="1.5"></circle>
                <text x="400" y="142" textAnchor="middle" fill="white" fontSize="9">Yelp API</text>
                <text x="400" y="154" textAnchor="middle" fill="#ef4444" fontSize="7">Photos + Rating</text>

                <circle cx="620" cy="145" r="22" fill="#111" stroke="#f59e0b" strokeWidth="1.5"></circle>
                <text x="620" y="138" textAnchor="middle" fill="white" fontSize="8">DoorDash</text>
                <text x="620" y="150" textAnchor="middle" fill="#f59e0b" fontSize="7">UberEats</text>

                <circle cx="400" cy="270" r="36" fill="#111" stroke="#8b5cf6" strokeWidth="2"></circle>
                <circle cx="400" cy="270" r="44" fill="none" stroke="#8b5cf6" strokeWidth="0.5" opacity="0.3"></circle>
                <text x="400" y="266" textAnchor="middle" fill="white" fontSize="11" fontWeight="600">Claude Vision</text>
                <text x="400" y="280" textAnchor="middle" fill="#8b5cf6" fontSize="8">by llm()</text>

                {[<circle cx={p["x"]} cy={p["y"]} r="22" fill="#111" stroke="#4ECDC4" strokeWidth="1.5"></circle> for p in products]}
                {[<text x={p["x"]} y={p["y"] - 3} textAnchor="middle" fill="white" fontSize="9">{p["name"]}</text> for p in products]}
                {[<text x={p["x"]} y={p["y"] + 9} textAnchor="middle" fill="#4ECDC4" fontSize="7">{p["category"]}</text> for p in products]}

                <circle cx="400" cy="540" r="28" fill="#111" stroke="#FF6B6B" strokeWidth="1.5"></circle>
                <text x="400" y="536" textAnchor="middle" fill="white" fontSize="10" fontWeight="500">Restaurant</text>
                <text x="400" y="549" textAnchor="middle" fill="#FF6B6B" fontSize="7">Brooklyn, NY</text>

                <circle cx="220" cy="630" r="22" fill="#111" stroke="#f59e0b" strokeWidth="1.5"></circle>
                <text x="220" y="627" textAnchor="middle" fill="white" fontSize="9">MCD Catalog</text>
                <text x="220" y="639" textAnchor="middle" fill="#f59e0b" fontSize="7">SKU Mapping</text>

                <circle cx="580" cy="630" r="22" fill="#111" stroke="#06b6d4" strokeWidth="1.5"></circle>
                <text x="580" y="627" textAnchor="middle" fill="white" fontSize="9">Tier Scoring</text>
                <text x="580" y="639" textAnchor="middle" fill="#06b6d4" fontSize="7">T1 / T2 / T3</text>

                <circle cx="400" cy="710" r="26" fill="#111" stroke="#f59e0b" strokeWidth="1.5"></circle>
                <text x="400" y="706" textAnchor="middle" fill="white" fontSize="9" fontWeight="500">Enriched Lead</text>
                <text x="400" y="719" textAnchor="middle" fill="#f59e0b" fontSize="7">Phone Email Products</text>

                <circle cx="80" cy="270" r="19" fill="#111" stroke="#ec4899" strokeWidth="1.5"></circle>
                <text x="80" y="267" textAnchor="middle" fill="white" fontSize="8">Correction</text>
                <text x="80" y="279" textAnchor="middle" fill="#ec4899" fontSize="7">Training</text>

                <circle cx="720" cy="270" r="19" fill="#111" stroke="#ec4899" strokeWidth="1.5"></circle>
                <text x="720" y="267" textAnchor="middle" fill="white" fontSize="8">AI Moat</text>
                <text x="720" y="279" textAnchor="middle" fill="#ec4899" fontSize="7">500+ fixes</text>
            </svg>
            <p style={{"textAlign": "center", "color": "#333", "fontSize": "0.65rem", "marginTop": "10px", "letterSpacing": "0.1em"}}>AUTONOMOUS AGENT: SCRAPE → IDENTIFY → ENRICH → ACT → LEARN</p>
        </div>;
    }
}
