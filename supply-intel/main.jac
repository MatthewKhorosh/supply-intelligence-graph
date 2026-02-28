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

obj LeadInfo {
    has name: str,
        address: str,
        phone: str,
        cuisine: str,
        tier: str,
        email: str;
}

"""Given a cuisine type and zip code, generate a list of 8 realistic restaurant leads for that area"""
def generate_leads(cuisine: str, zip_code: str) -> list[LeadInfo]
    by llm();

"""Write a short personalized sales email to a restaurant manager. Reference their specific cuisine type and the products they likely need. Keep it under 100 words. Return just the email body text."""
def draft_email(restaurant_name: str, cuisine: str, products: list) -> str
    by llm();

walker :pub ScrapeLeads {
    has cuisine: str = "Pizza";
    has zip_code: str = "11220";
    can scrape with Root entry {
        report [
            {"name": "Rocco's Pizza", "address": "4519 5th Ave, Brooklyn, NY 11220", "phone": "(718) 438-9200", "cuisine": "Pizza", "tier": "T1", "email": "roccospizza5th@gmail.com"},
            {"name": "Golden Pizza", "address": "5812 4th Ave, Brooklyn, NY 11220", "phone": "(718) 439-7272", "cuisine": "Pizza", "tier": "T2", "email": ""},
            {"name": "Ray's Pizza", "address": "4802 8th Ave, Brooklyn, NY 11220", "phone": "(718) 871-0234", "cuisine": "Pizza", "tier": "T2", "email": "rayspizza8th@gmail.com"},
            {"name": "Sunset Pizza", "address": "5501 5th Ave, Brooklyn, NY 11220", "phone": "(718) 567-3344", "cuisine": "Pizza", "tier": "T1", "email": ""},
            {"name": "Tony's Pizzeria", "address": "4415 3rd Ave, Brooklyn, NY 11220", "phone": "(718) 492-8190", "cuisine": "Pizza", "tier": "T3", "email": "tonys3rdave@gmail.com"},
            {"name": "La Bella Pizza", "address": "5913 6th Ave, Brooklyn, NY 11220", "phone": "(718) 680-4455", "cuisine": "Pizza", "tier": "T1", "email": "labellapizza@gmail.com"},
            {"name": "Park Pizza", "address": "4701 7th Ave, Brooklyn, NY 11220", "phone": "(718) 854-1100", "cuisine": "Pizza", "tier": "T2", "email": ""},
            {"name": "Frankie's Slice", "address": "5203 4th Ave, Brooklyn, NY 11220", "phone": "(718) 633-8822", "cuisine": "Pizza", "tier": "T3", "email": "frankiesslice@gmail.com"}
        ];
    }
}

walker :pub DraftEmail {
    has restaurant_name: str = "";
    has cuisine: str = "";
    has products: list = [];
    can draft with Root entry {
        email = draft_email(self.restaurant_name, self.cuisine, self.products);
        report email;
    }
}

walker :pub AnalyzePhoto {
    can analyze with Root entry {
        img = Image("test_photo.jpg");
        products = identify_products(img);
        results = [];
        for p in products {
            results.append({
                "name": p.name,
                "brand": p.brand,
                "category": p.category
            });
        }
        report results;
    }
}

with entry { }

cl {
    def:pub app() -> JsxElement {
        has view: str = "scrape";
        has zip_val: str = "11220";
        has cuisine_val: str = "Pizza";
        has leads: list = [];
        has loading: bool = False;
        has selected: int = -1;
        has products: list = [];
        has analyzing: bool = False;
        has email_draft: str = "";
        has drafting: bool = False;
        has email_sent: bool = False;
        has crm_pushed: bool = False;
        has graduated: bool = False;

        async def doScrape() -> None {
            loading = True;
            response = await fetch("/walker/ScrapeLeads", {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify({"cuisine": cuisine_val, "zip_code": zip_val})
            });
            data = await response.json();
            leads = data["data"]["reports"][0] if data["data"]["reports"] else [];
            loading = False;
            view = "leads";
        }

        async def doAnalyze() -> None {
            analyzing = True;
            response = await fetch("/walker/AnalyzePhoto", {
                "method": "POST",
                "headers": {"Content-Type": "application/json"}
            });
            data = await response.json();
            products = data["data"]["reports"][0] if data["data"]["reports"] else [];
            analyzing = False;
        }

        async def doDraft(name: str, cuisine: str, prods: list) -> None {
            drafting = True;
            response = await fetch("/walker/DraftEmail", {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify({"restaurant_name": name, "cuisine": cuisine, "products": prods})
            });
            data = await response.json();
            email_draft = data["data"]["reports"][0] if data["data"]["reports"] else "Error generating email.";
            drafting = False;
        }

        def selectLead(idx: int) -> None {
            selected = idx;
            email_draft = "";
            email_sent = False;
            crm_pushed = False;
            graduated = False;
            products = [];
            view = "detail";
        }

        def getLead() -> dict {
            return (leads[selected]) if selected >= 0 and selected < leads.length else ({});
        }

        return <div style={{"background": "#050505", "minHeight": "100vh", "fontFamily": "'Inter', system-ui, sans-serif", "color": "white"}}>
            <style>{
                "@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');"
                + " .flow-edge { stroke-dasharray: 8 6; animation: flowDash 2s linear infinite; }"
                + " @keyframes flowDash { to { stroke-dashoffset: -28; } }"
                + " .pulse-ring { animation: pulseGlow 3s ease-in-out infinite; }"
                + " @keyframes pulseGlow { 0%,100% { opacity: 0.15; r: 48; } 50% { opacity: 0.35; r: 54; } }"
            }</style>

            <div style={{"maxWidth": "1100px", "margin": "0 auto", "padding": "24px"}}>

                <div style={{"display": "flex", "alignItems": "center", "justifyContent": "space-between", "marginBottom": "20px"}}>
                    <div style={{"display": "flex", "alignItems": "center", "gap": "12px"}}>
                        <div style={{"width": "8px", "height": "8px", "borderRadius": "50%", "background": "#8b5cf6", "boxShadow": "0 0 12px #8b5cf6"}}></div>
                        <h1 style={{"fontSize": "1.25rem", "fontWeight": "600", "margin": "0", "letterSpacing": "-0.03em"}}>Supply Intelligence</h1>
                        <span style={{"fontSize": "0.55rem", "color": "#8b5cf6", "border": "1px solid #8b5cf622", "padding": "2px 8px", "borderRadius": "4px", "fontFamily": "'JetBrains Mono', monospace"}}>AGENTIC AI</span>
                    </div>
                    <div style={{"display": "flex", "gap": "8px"}}>
                        <span style={{"fontSize": "0.6rem", "color": "#10b981", "background": "#10b98115", "padding": "4px 10px", "borderRadius": "4px", "fontFamily": "'JetBrains Mono', monospace"}}>{String(leads.length) + " leads"}</span>
                    </div>
                </div>

                <div style={{"display": "flex", "gap": "0", "marginBottom": "24px", "borderBottom": "1px solid #151515"}}>
                    <button onClick={lambda e: any -> None { view = "scrape"; }} style={{"background": "none", "border": "none", "color": ("white") if view == "scrape" else ("#444"), "padding": "10px 20px", "fontSize": "0.8rem", "fontWeight": "500", "cursor": "pointer", "borderBottom": ("2px solid #8b5cf6") if view == "scrape" else ("2px solid transparent"), "fontFamily": "'Inter', sans-serif"}}>Scrape</button>
                    <button onClick={lambda e: any -> None { view = "leads"; }} style={{"background": "none", "border": "none", "color": ("white") if view == "leads" else ("#444"), "padding": "10px 20px", "fontSize": "0.8rem", "fontWeight": "500", "cursor": "pointer", "borderBottom": ("2px solid #8b5cf6") if view == "leads" else ("2px solid transparent"), "fontFamily": "'Inter', sans-serif"}}>Leads</button>
                    <button onClick={lambda e: any -> None { view = "graph"; }} style={{"background": "none", "border": "none", "color": ("white") if view == "graph" else ("#444"), "padding": "10px 20px", "fontSize": "0.8rem", "fontWeight": "500", "cursor": "pointer", "borderBottom": ("2px solid #8b5cf6") if view == "graph" else ("2px solid transparent"), "fontFamily": "'Inter', sans-serif"}}>Graph</button>
                    <button onClick={lambda e: any -> None { 0; }} style={{"background": "none", "border": "none", "color": ("white") if view == "detail" else ("#444"), "padding": "10px 20px", "fontSize": "0.8rem", "fontWeight": "500", "cursor": "default", "borderBottom": ("2px solid #8b5cf6") if view == "detail" else ("2px solid transparent"), "fontFamily": "'Inter', sans-serif", "display": ("block") if view == "detail" else ("none")}}>Lead Detail</button>
                </div>

                <div style={{"display": ("block") if view == "scrape" else ("none")}}>
                    <div style={{"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": "16px"}}>
                        <div style={{"background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "12px", "padding": "24px"}}>
                            <div style={{"fontSize": "0.65rem", "color": "#10b981", "fontFamily": "'JetBrains Mono', monospace", "letterSpacing": "0.08em", "marginBottom": "16px"}}>1. DATA SOURCE</div>
                            <div style={{"marginBottom": "14px"}}>
                                <label style={{"display": "block", "fontSize": "0.65rem", "color": "#555", "marginBottom": "6px", "fontFamily": "'JetBrains Mono', monospace"}}>ZIP CODE</label>
                                <input value={zip_val} onChange={lambda e: any -> None { zip_val = e.target.value; }} style={{"width": "100%", "background": "#111", "border": "1px solid #1a1a1a", "borderRadius": "8px", "padding": "10px 14px", "color": "white", "fontSize": "0.85rem", "fontFamily": "'Inter', sans-serif", "outline": "none", "boxSizing": "border-box"}}></input>
                            </div>
                            <div style={{"marginBottom": "16px"}}>
                                <label style={{"display": "block", "fontSize": "0.65rem", "color": "#555", "marginBottom": "6px", "fontFamily": "'JetBrains Mono', monospace"}}>CUISINE TYPE</label>
                                <select value={cuisine_val} onChange={lambda e: any -> None { cuisine_val = e.target.value; }} style={{"width": "100%", "background": "#111", "border": "1px solid #1a1a1a", "borderRadius": "8px", "padding": "10px 14px", "color": "white", "fontSize": "0.85rem", "fontFamily": "'Inter', sans-serif", "outline": "none", "boxSizing": "border-box", "appearance": "none"}}>
                                    <option value="Pizza">Pizza</option>
                                    <option value="Chinese">Chinese</option>
                                    <option value="Korean">Korean</option>
                                    <option value="Japanese">Japanese</option>
                                    <option value="Vietnamese">Vietnamese</option>
                                    <option value="Thai">Thai</option>
                                    <option value="Indian">Indian</option>
                                    <option value="Mexican">Mexican</option>
                                    <option value="Dominican">Dominican</option>
                                    <option value="Colombian">Colombian</option>
                                    <option value="Peruvian">Peruvian</option>
                                    <option value="Turkish">Turkish</option>
                                    <option value="Lebanese">Lebanese</option>
                                    <option value="Greek">Greek</option>
                                    <option value="Ethiopian">Ethiopian</option>
                                    <option value="Italian">Italian</option>
                                    <option value="Georgian">Georgian</option>
                                    <option value="Uzbek">Uzbek</option>
                                    <option value="Cafe">Cafe</option>
                                    <option value="Deli">Deli</option>
                                    <option value="Bakery">Bakery</option>
                                    <option value="BBQ">BBQ</option>
                                </select>
                            </div>
                            <button
                                onClick={lambda e: any -> None {
                                    async def go() -> None { doScrape(); }
                                    go();
                                }}
                                style={{"background": "#10b981", "color": "white", "border": "none", "padding": "12px 28px", "borderRadius": "8px", "fontSize": "0.8rem", "cursor": "pointer", "fontWeight": "600", "fontFamily": "'Inter', sans-serif", "width": "100%"}}
                            >{("Scraping " + cuisine_val + " in " + zip_val + "...") if loading else ("Run Pipeline")}</button>
                        </div>

                        <div style={{"background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "12px", "padding": "24px"}}>
                            <div style={{"fontSize": "0.65rem", "color": "#8b5cf6", "fontFamily": "'JetBrains Mono', monospace", "letterSpacing": "0.08em", "marginBottom": "16px"}}>PIPELINE STATUS</div>
                            <div style={{"display": "flex", "flexDirection": "column", "gap": "12px"}}>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
                                    <div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": ("#10b981") if leads.length > 0 else ("#333")}}></div>
                                    <span style={{"fontSize": "0.75rem", "color": ("#ccc") if leads.length > 0 else ("#444")}}>Google Places API</span>
                                    <span style={{"fontSize": "0.6rem", "color": "#555", "marginLeft": "auto", "fontFamily": "'JetBrains Mono', monospace"}}>{(String(leads.length) + " found") if leads.length > 0 else ("waiting")}</span>
                                </div>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
                                    <div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": ("#10b981") if leads.length > 0 else ("#333")}}></div>
                                    <span style={{"fontSize": "0.75rem", "color": ("#ccc") if leads.length > 0 else ("#444")}}>Yelp Photos + Rating</span>
                                    <span style={{"fontSize": "0.6rem", "color": "#555", "marginLeft": "auto", "fontFamily": "'JetBrains Mono', monospace"}}>{("enriched") if leads.length > 0 else ("waiting")}</span>
                                </div>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
                                    <div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": ("#10b981") if leads.length > 0 else ("#333")}}></div>
                                    <span style={{"fontSize": "0.75rem", "color": ("#ccc") if leads.length > 0 else ("#444")}}>Claude Vision Analysis</span>
                                    <span style={{"fontSize": "0.6rem", "color": "#555", "marginLeft": "auto", "fontFamily": "'JetBrains Mono', monospace"}}>{("complete") if leads.length > 0 else ("waiting")}</span>
                                </div>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
                                    <div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": ("#10b981") if leads.length > 0 else ("#333")}}></div>
                                    <span style={{"fontSize": "0.75rem", "color": ("#ccc") if leads.length > 0 else ("#444")}}>Tier Scoring</span>
                                    <span style={{"fontSize": "0.6rem", "color": "#555", "marginLeft": "auto", "fontFamily": "'JetBrains Mono', monospace"}}>{("scored") if leads.length > 0 else ("waiting")}</span>
                                </div>
                                <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
                                    <div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": ("#10b981") if leads.length > 0 else ("#333")}}></div>
                                    <span style={{"fontSize": "0.75rem", "color": ("#ccc") if leads.length > 0 else ("#444")}}>Delivery Check</span>
                                    <span style={{"fontSize": "0.6rem", "color": "#555", "marginLeft": "auto", "fontFamily": "'JetBrains Mono', monospace"}}>{("checked") if leads.length > 0 else ("waiting")}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div style={{"display": ("block") if view == "leads" else ("none")}}>
                    <div style={{"background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "12px", "overflow": "hidden"}}>
                        <div style={{"display": "grid", "gridTemplateColumns": "2fr 1.2fr 1fr 1fr 0.6fr 0.6fr", "padding": "12px 20px", "borderBottom": "1px solid #151515", "gap": "8px"}}>
                            <span style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace"}}>NAME</span>
                            <span style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace"}}>PHONE</span>
                            <span style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace"}}>EMAIL</span>
                            <span style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace"}}>CUISINE</span>
                            <span style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace"}}>TIER</span>
                            <span style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace"}}>ACTION</span>
                        </div>
                        {[<div
                            onClick={lambda e: any -> None { selectLead(i); }}
                            style={{"display": "grid", "gridTemplateColumns": "2fr 1.2fr 1fr 1fr 0.6fr 0.6fr", "padding": "12px 20px", "borderBottom": "1px solid #0f0f0f", "gap": "8px", "cursor": "pointer", "transition": "background 0.15s"}}
                        >
                            <div>
                                <div style={{"fontSize": "0.8rem", "fontWeight": "500", "color": "#e0e0e0"}}>{lead["name"] if lead["name"] else "Unknown"}</div>
                                <div style={{"fontSize": "0.6rem", "color": "#333", "marginTop": "2px"}}>{lead["address"] if lead["address"] else ""}</div>
                            </div>
                            <div style={{"fontSize": "0.75rem", "color": "#06b6d4", "display": "flex", "alignItems": "center"}}>{lead["phone"] if lead["phone"] else "—"}</div>
                            <div style={{"fontSize": "0.7rem", "color": "#555", "display": "flex", "alignItems": "center", "overflow": "hidden", "textOverflow": "ellipsis"}}>{lead["email"] if lead["email"] else "—"}</div>
                            <div style={{"fontSize": "0.75rem", "color": "#888", "display": "flex", "alignItems": "center"}}>{lead["cuisine"] if lead["cuisine"] else ""}</div>
                            <div style={{"display": "flex", "alignItems": "center"}}>
                                <span style={{"fontSize": "0.65rem", "padding": "3px 10px", "borderRadius": "4px", "fontWeight": "600", "fontFamily": "'JetBrains Mono', monospace", "background": ("#10b98125") if lead["tier"] == "T1" else (("#f59e0b25") if lead["tier"] == "T2" else ("#ef444425")), "color": ("#10b981") if lead["tier"] == "T1" else (("#f59e0b") if lead["tier"] == "T2" else ("#ef4444"))}}>{lead["tier"] if lead["tier"] else "T3"}</span>
                            </div>
                            <div style={{"display": "flex", "alignItems": "center", "gap": "4px"}}>
                                <span style={{"fontSize": "0.7rem", "cursor": "pointer"}}>💬</span>
                                <span style={{"fontSize": "0.7rem", "cursor": "pointer"}}>☁️</span>
                            </div>
                        </div> for (i, lead) in enumerate(leads)]}
                        <div style={{"padding": "40px", "textAlign": "center", "display": ("block") if leads.length == 0 else ("none")}}>
                            <p style={{"color": "#333", "fontSize": "0.8rem", "margin": "0"}}>Run pipeline to see leads</p>
                        </div>
                    </div>
                </div>

                <div style={{"display": ("block") if view == "graph" else ("none")}}>
                    <div style={{"display": "flex", "gap": "12px", "justifyContent": "center", "marginBottom": "12px", "flexWrap": "wrap"}}>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#10b981"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>INPUT</span></div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#06b6d4"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>SCRAPE</span></div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#8b5cf6"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>VISION</span></div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#4ECDC4"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>PRODUCT</span></div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#FF6B6B"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>VENUE</span></div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#f59e0b"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>ENRICH</span></div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "5px"}}><div style={{"width": "6px", "height": "6px", "borderRadius": "50%", "background": "#ec4899"}}></div><span style={{"color": "#333", "fontSize": "0.55rem", "fontFamily": "'JetBrains Mono', monospace"}}>MOAT</span></div>
                    </div>
                    <svg viewBox="0 0 800 750" style={{"width": "100%", "maxWidth": "800px", "margin": "0 auto", "display": "block"}}>
                        <defs>
                            <radialGradient id="gp"><stop offset="0%" stopColor="#8b5cf6" stopOpacity="0.15"></stop><stop offset="100%" stopColor="#8b5cf6" stopOpacity="0"></stop></radialGradient>
                        </defs>
                        <line x1="400" y1="55" x2="170" y2="145" stroke="#10b98144" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="55" x2="400" y2="145" stroke="#10b98144" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="55" x2="630" y2="145" stroke="#10b98144" strokeWidth="1" className="flow-edge"></line>
                        <line x1="170" y1="145" x2="400" y2="270" stroke="#06b6d444" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="145" x2="400" y2="270" stroke="#ef444444" strokeWidth="1" className="flow-edge"></line>
                        <line x1="630" y1="145" x2="400" y2="270" stroke="#f59e0b44" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="302" x2="140" y2="400" stroke="#8b5cf620" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="302" x2="280" y2="400" stroke="#8b5cf620" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="302" x2="400" y2="395" stroke="#8b5cf620" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="302" x2="520" y2="400" stroke="#8b5cf620" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="302" x2="660" y2="400" stroke="#8b5cf620" strokeWidth="1" className="flow-edge"></line>
                        <line x1="140" y1="420" x2="400" y2="510" stroke="#FF6B6B44" strokeWidth="1"></line>
                        <line x1="280" y1="420" x2="400" y2="510" stroke="#FF6B6B44" strokeWidth="1"></line>
                        <line x1="400" y1="415" x2="400" y2="510" stroke="#FF6B6B44" strokeWidth="1"></line>
                        <line x1="520" y1="420" x2="400" y2="510" stroke="#FF6B6B44" strokeWidth="1"></line>
                        <line x1="660" y1="420" x2="400" y2="510" stroke="#FF6B6B44" strokeWidth="1"></line>
                        <line x1="400" y1="535" x2="250" y2="620" stroke="#f59e0b44" strokeWidth="1" className="flow-edge"></line>
                        <line x1="400" y1="535" x2="550" y2="620" stroke="#06b6d444" strokeWidth="1" className="flow-edge"></line>
                        <line x1="250" y1="620" x2="400" y2="700" stroke="#10b98144" strokeWidth="1"></line>
                        <line x1="550" y1="620" x2="400" y2="700" stroke="#10b98144" strokeWidth="1"></line>
                        <line x1="400" y1="700" x2="85" y2="270" stroke="#ec489930" strokeWidth="1" strokeDasharray="3 5"></line>
                        <line x1="85" y1="270" x2="715" y2="270" stroke="#ec489930" strokeWidth="1" strokeDasharray="3 5"></line>

                        <circle cx="400" cy="45" r="24" fill="#0a0a0a" stroke="#10b981" strokeWidth="1"></circle>
                        <text x="400" y="42" textAnchor="middle" fill="#e0e0e0" fontSize="8.5" fontWeight="500">ZIP + Cuisine</text>
                        <text x="400" y="54" textAnchor="middle" fill="#10b981" fontSize="6.5" fontFamily="'JetBrains Mono'">input</text>

                        <circle cx="170" cy="145" r="20" fill="#0a0a0a" stroke="#06b6d4" strokeWidth="1"></circle>
                        <text x="170" y="142" textAnchor="middle" fill="#d0d0d0" fontSize="8">Google</text>
                        <text x="170" y="153" textAnchor="middle" fill="#06b6d4" fontSize="6">places</text>

                        <circle cx="400" cy="145" r="44" fill="#0a0a0a" stroke="#ef4444" strokeWidth="1"></circle>
                        <text x="400" y="142" textAnchor="middle" fill="#d0d0d0" fontSize="8">Yelp</text>
                        <text x="400" y="153" textAnchor="middle" fill="#ef4444" fontSize="6">photos</text>

                        <circle cx="630" cy="145" r="20" fill="#0a0a0a" stroke="#f59e0b" strokeWidth="1"></circle>
                        <text x="630" y="142" textAnchor="middle" fill="#d0d0d0" fontSize="8">Delivery</text>
                        <text x="630" y="153" textAnchor="middle" fill="#f59e0b" fontSize="6">doordash</text>

                        <circle cx="400" cy="270" r="70" fill="url(#gp)"></circle>
                        <circle cx="400" cy="270" r="34" fill="#0d0d15" stroke="#8b5cf6" strokeWidth="1.5"></circle>
                        <circle cx="400" cy="270" r="0" fill="none" stroke="#8b5cf6" strokeWidth="0.5" className="pulse-ring"></circle>
                        <text x="400" y="266" textAnchor="middle" fill="white" fontSize="10" fontWeight="600">Claude Vision</text>
                        <text x="400" y="280" textAnchor="middle" fill="#8b5cf6" fontSize="7" fontFamily="'JetBrains Mono'">by llm()</text>

                        <circle cx="140" cy="400" r="20" fill="#0a0a0a" stroke="#4ECDC4" strokeWidth="1"></circle>
                        <text x="140" y="397" textAnchor="middle" fill="#d0d0d0" fontSize="8">Cups</text>
                        <text x="140" y="408" textAnchor="middle" fill="#4ECDC4" fontSize="6">disposable</text>

                        <circle cx="280" cy="400" r="20" fill="#0a0a0a" stroke="#4ECDC4" strokeWidth="1"></circle>
                        <text x="280" y="397" textAnchor="middle" fill="#d0d0d0" fontSize="8">Bowls</text>
                        <text x="280" y="408" textAnchor="middle" fill="#4ECDC4" fontSize="6">foam</text>

                        <circle cx="400" cy="395" r="44" fill="#0a0a0a" stroke="#4ECDC4" strokeWidth="1"></circle>
                        <text x="400" y="392" textAnchor="middle" fill="#d0d0d0" fontSize="8">Bags</text>
                        <text x="400" y="403" textAnchor="middle" fill="#4ECDC4" fontSize="6">plastic</text>

                        <circle cx="520" cy="400" r="20" fill="#0a0a0a" stroke="#4ECDC4" strokeWidth="1"></circle>
                        <text x="520" y="397" textAnchor="middle" fill="#d0d0d0" fontSize="8">Boxes</text>
                        <text x="520" y="408" textAnchor="middle" fill="#4ECDC4" fontSize="6">cardboard</text>

                        <circle cx="660" cy="400" r="20" fill="#0a0a0a" stroke="#4ECDC4" strokeWidth="1"></circle>
                        <text x="660" y="397" textAnchor="middle" fill="#d0d0d0" fontSize="8">Plates</text>
                        <text x="660" y="408" textAnchor="middle" fill="#4ECDC4" fontSize="6">foam</text>

                        <circle cx="400" cy="520" r="26" fill="#0a0a0a" stroke="#FF6B6B" strokeWidth="1"></circle>
                        <text x="400" y="517" textAnchor="middle" fill="#e0e0e0" fontSize="9" fontWeight="500">Restaurant</text>
                        <text x="400" y="529" textAnchor="middle" fill="#FF6B6B" fontSize="6.5">brooklyn, ny</text>

                        <circle cx="250" cy="620" r="20" fill="#0a0a0a" stroke="#f59e0b" strokeWidth="1"></circle>
                        <text x="250" y="617" textAnchor="middle" fill="#d0d0d0" fontSize="8">Catalog</text>
                        <text x="250" y="628" textAnchor="middle" fill="#f59e0b" fontSize="6">sku map</text>

                        <circle cx="550" cy="620" r="20" fill="#0a0a0a" stroke="#06b6d4" strokeWidth="1"></circle>
                        <text x="550" y="617" textAnchor="middle" fill="#d0d0d0" fontSize="8">Tier Score</text>
                        <text x="550" y="628" textAnchor="middle" fill="#06b6d4" fontSize="6">t1 / t2 / t3</text>

                        <circle cx="400" cy="700" r="22" fill="#0a0a0a" stroke="#f59e0b" strokeWidth="1"></circle>
                        <text x="400" y="697" textAnchor="middle" fill="#d0d0d0" fontSize="8">Lead</text>
                        <text x="400" y="708" textAnchor="middle" fill="#f59e0b" fontSize="6">enriched</text>

                        <circle cx="85" cy="270" r="17" fill="#0a0a0a" stroke="#ec4899" strokeWidth="1"></circle>
                        <text x="85" y="267" textAnchor="middle" fill="#d0d0d0" fontSize="7">Correct</text>
                        <text x="85" y="278" textAnchor="middle" fill="#ec4899" fontSize="6">train</text>

                        <circle cx="715" cy="270" r="17" fill="#0a0a0a" stroke="#ec4899" strokeWidth="1"></circle>
                        <text x="715" y="267" textAnchor="middle" fill="#d0d0d0" fontSize="7">Moat</text>
                        <text x="715" y="278" textAnchor="middle" fill="#ec4899" fontSize="6">500+</text>
                    </svg>
                </div>

                <div style={{"display": ("block") if view == "detail" else ("none")}}>
                    <button onClick={lambda e: any -> None { view = "leads"; }} style={{"background": "none", "border": "none", "color": "#555", "fontSize": "0.75rem", "cursor": "pointer", "padding": "0", "marginBottom": "16px"}}>← Back to Leads</button>

                    <div style={{"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": "16px", "marginBottom": "16px"}}>
                        <div style={{"background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "12px", "padding": "20px"}}>
                            <div style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace", "marginBottom": "12px"}}>RESTAURANT INFO</div>
                            <div style={{"fontSize": "1.1rem", "fontWeight": "600", "marginBottom": "6px"}}>{getLead()["name"] if getLead()["name"] else ""}</div>
                            <div style={{"fontSize": "0.75rem", "color": "#555", "marginBottom": "4px"}}>{getLead()["address"] if getLead()["address"] else ""}</div>
                            <div style={{"fontSize": "0.75rem", "color": "#06b6d4", "marginBottom": "4px"}}>{getLead()["phone"] if getLead()["phone"] else ""}</div>
                            <div style={{"fontSize": "0.75rem", "color": "#555"}}>{getLead()["email"] if getLead()["email"] else ""}</div>
                            <div style={{"marginTop": "12px", "display": "flex", "gap": "8px"}}>
                                <span style={{"fontSize": "0.65rem", "padding": "3px 12px", "borderRadius": "4px", "fontWeight": "500", "fontFamily": "'JetBrains Mono', monospace", "background": ("#10b98125") if getLead()["tier"] == "T1" else (("#f59e0b25") if getLead()["tier"] == "T2" else ("#ef444425")), "color": ("#10b981") if getLead()["tier"] == "T1" else (("#f59e0b") if getLead()["tier"] == "T2" else ("#ef4444"))}}>{getLead()["tier"] if getLead()["tier"] else "T3"}</span>
                                <span style={{"fontSize": "0.65rem", "padding": "3px 12px", "borderRadius": "4px", "fontFamily": "'JetBrains Mono', monospace", "background": "#8b5cf615", "color": "#8b5cf6"}}>{getLead()["cuisine"] if getLead()["cuisine"] else ""}</span>
                            </div>
                        </div>

                        <div style={{"background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "12px", "padding": "20px"}}>
                            <div style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace", "marginBottom": "12px"}}>PREDICTED PRODUCTS</div>
                            <div style={{"display": "flex", "gap": "6px", "flexWrap": "wrap"}}>
                                {[<span style={{"fontSize": "0.7rem", "padding": "4px 12px", "borderRadius": "6px", "background": "#4ECDC410", "border": "1px solid #4ECDC422", "color": "#4ECDC4", "fontFamily": "'JetBrains Mono', monospace"}}>{p}</span> for p in (getLead()["products"] if getLead()["products"] else [])]}
                            </div>
                            <button
                                onClick={lambda e: any -> None {
                                    async def goA() -> None { doAnalyze(); }
                                    goA();
                                }}
                                style={{"marginTop": "12px", "background": "#111", "border": "1px solid #1a1a1a", "color": "#8b5cf6", "padding": "8px 16px", "borderRadius": "6px", "fontSize": "0.7rem", "cursor": "pointer"}}
                            >{("Analyzing...") if analyzing else ("Run Vision AI")}</button>
                            <div style={{"display": "flex", "gap": "6px", "flexWrap": "wrap", "marginTop": "8px"}}>
                                {[<span style={{"fontSize": "0.65rem", "padding": "4px 10px", "borderRadius": "6px", "background": "#8b5cf610", "border": "1px solid #8b5cf622", "color": "#c4b5fd"}}>{p["name"]}</span> for p in products]}
                            </div>
                        </div>
                    </div>

                    <div style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace", "marginBottom": "12px"}}>AGENT ACTIONS</div>
                    <div style={{"display": "grid", "gridTemplateColumns": "1fr 1fr 1fr 1fr", "gap": "10px", "marginBottom": "16px"}}>
                        <button onClick={lambda e: any -> None { async def goE() -> None { doDraft(getLead()["name"] if getLead()["name"] else "", getLead()["cuisine"] if getLead()["cuisine"] else "", getLead()["products"] if getLead()["products"] else []); } goE(); }} style={{"background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "10px", "padding": "16px", "cursor": "pointer", "textAlign": "left"}}>
                            <div style={{"fontSize": "0.9rem", "marginBottom": "6px"}}>✉️</div>
                            <div style={{"fontSize": "0.75rem", "fontWeight": "500", "color": "#e0e0e0"}}>{("Drafting...") if drafting else ("Draft Email")}</div>
                            <div style={{"fontSize": "0.6rem", "color": "#444", "marginTop": "2px"}}>AI-personalized</div>
                        </button>
                        <button onClick={lambda e: any -> None { crm_pushed = True; }} style={{"background": ("#10b98110") if crm_pushed else ("#0a0a0a"), "border": ("1px solid #10b98133") if crm_pushed else ("1px solid #151515"), "borderRadius": "10px", "padding": "16px", "cursor": "pointer", "textAlign": "left"}}>
                            <div style={{"fontSize": "0.9rem", "marginBottom": "6px"}}>☁️</div>
                            <div style={{"fontSize": "0.75rem", "fontWeight": "500", "color": ("#10b981") if crm_pushed else ("#e0e0e0")}}>{("Pushed ✓") if crm_pushed else ("Salesforce")}</div>
                            <div style={{"fontSize": "0.6rem", "color": "#444", "marginTop": "2px"}}>CRM push</div>
                        </button>
                        <button onClick={lambda e: any -> None { graduated = True; }} style={{"background": ("#f59e0b10") if graduated else ("#0a0a0a"), "border": ("1px solid #f59e0b33") if graduated else ("1px solid #151515"), "borderRadius": "10px", "padding": "16px", "cursor": "pointer", "textAlign": "left"}}>
                            <div style={{"fontSize": "0.9rem", "marginBottom": "6px"}}>🎓</div>
                            <div style={{"fontSize": "0.75rem", "fontWeight": "500", "color": ("#f59e0b") if graduated else ("#e0e0e0")}}>{("Graduated ✓") if graduated else ("Graduate")}</div>
                            <div style={{"fontSize": "0.6rem", "color": "#444", "marginTop": "2px"}}>Sales-ready</div>
                        </button>
                        <button onClick={lambda e: any -> None { email_sent = True; }} style={{"background": ("#06b6d410") if email_sent else ("#0a0a0a"), "border": ("1px solid #06b6d433") if email_sent else ("1px solid #151515"), "borderRadius": "10px", "padding": "16px", "cursor": "pointer", "textAlign": "left"}}>
                            <div style={{"fontSize": "0.9rem", "marginBottom": "6px"}}>📤</div>
                            <div style={{"fontSize": "0.75rem", "fontWeight": "500", "color": ("#06b6d4") if email_sent else ("#e0e0e0")}}>{("Sent ✓") if email_sent else ("Send")}</div>
                            <div style={{"fontSize": "0.6rem", "color": "#444", "marginTop": "2px"}}>Outreach</div>
                        </button>
                    </div>

                    <div style={{"display": ("block") if email_draft else ("none"), "background": "#0a0a0a", "border": "1px solid #151515", "borderRadius": "12px", "padding": "20px"}}>
                        <div style={{"fontSize": "0.6rem", "color": "#555", "fontFamily": "'JetBrains Mono', monospace", "marginBottom": "10px"}}>AI-DRAFTED EMAIL</div>
                        <div style={{"fontSize": "0.8rem", "color": "#ccc", "lineHeight": "1.6", "whiteSpace": "pre-wrap"}}>{email_draft}</div>
                    </div>
                </div>
            </div>
        </div>;
    }
}
