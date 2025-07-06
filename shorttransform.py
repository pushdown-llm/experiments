import xml.etree.ElementTree as ET
import re
import os
import copy

def is_empty_element(element):
    """Check if an element is effectively empty (no children and no text content)"""
    has_children = len(list(element)) > 0
    has_text = element.text and element.text.strip()
    has_tail = element.tail and element.tail.strip()
    has_attributes = len(element.attrib) > 0
    
    return not (has_children or has_text or has_tail or has_attributes)

def clean_empty_elements(element):
    """Recursively remove empty elements"""
    children = list(element)
    for child in children:
        clean_empty_elements(child)
        if is_empty_element(child):
            element.remove(child)

def extract_order_and_steps(xml_content):
    # Parse the XML
    root = ET.fromstring(xml_content)
    
    # Find the transformation element
    transformation = root
    if root.tag != 'transformation':
        transformations = root.findall('.//transformation')
        if transformations:
            transformation = transformations[0]
    
    # Create a new transformation with only selected elements
    new_transformation = ET.Element('transformation')
    
    # Find and copy all order elements
    order_elements = transformation.findall('./order')
    for order_elem in order_elements:
        new_order = copy.deepcopy(order_elem)
        new_transformation.append(new_order)
    
    # Find and copy all step elements (with filtering)
    step_elements = transformation.findall('./step')
    for step_elem in step_elements:
        # Create a deep copy of the step element
        new_step = copy.deepcopy(step_elem)
        
        # Remove GUI elements
        for gui in new_step.findall('./GUI'):
            new_step.remove(gui)
        
        # Find and filter value-meta elements
        for row_meta in new_step.findall('.//row-meta'):
            for value_meta in row_meta.findall('./value-meta'):
                # Keep only type, name, length, and precision elements
                keep_elements = ['type', 'name', 'length', 'precision']
                
                # Remove child elements that we don't want to keep
                for child in list(value_meta):
                    if child.tag not in keep_elements:
                        value_meta.remove(child)
        
        # Clean up empty elements
        clean_empty_elements(new_step)
        
        # Only add the step if it's not empty after cleanup
        if not is_empty_element(new_step):
            new_transformation.append(new_step)
    
    # Final cleanup of empty elements in the transformation
    clean_empty_elements(new_transformation)
    
    # Convert to string
    xml_str = ET.tostring(new_transformation, encoding='unicode')
    
    # Custom pretty-printing approach that doesn't escape quotes
    pretty_xml = pretty_print_xml(xml_str)
    
    return pretty_xml

def pretty_print_xml(xml_string):
    """Custom pretty printing that doesn't escape quotes and special characters"""
    import xml.dom.minidom
    
    # Parse the XML string
    dom = xml.dom.minidom.parseString(xml_string)
    
    # Get a pretty-printed XML string with indentation
    pretty_xml = dom.toprettyxml(indent="  ")
    
    # Remove extra empty lines
    pretty_xml = re.sub(r'\n\s*\n+', '\n', pretty_xml)
    
    # Un-escape entities that minidom might have escaped
    replacements = [
        ('&quot;', '"'),
        ('&apos;', "'"),
        ('&lt;', '<'),
        ('&gt;', '>'),
        ('&amp;', '&')
    ]
    
    for escaped, original in replacements:
        pretty_xml = pretty_xml.replace(escaped, original)
    
    return pretty_xml

def process_file(input_file, output_file=None):
    # Read input file
    with open(input_file, 'r', encoding='utf-8') as f:
        xml_content = f.read()
    
    # Extract the transformation content if embedded in a document
    match = re.search(r'<transformation>(.*?)</transformation>', xml_content, re.DOTALL)
    if match:
        xml_content = f'<transformation>{match.group(1)}</transformation>'
    
    # Extract and clean up elements
    result = extract_order_and_steps(xml_content)
    
    # Handle output file
    if not output_file:
        base_name = os.path.splitext(input_file)[0]
        output_file = f"{base_name}_extracted.xml"
    else:
        if not output_file.lower().endswith('.xml'):
            output_file += '.xml'
    
    # Write result to output file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(result)
    
    print(f"Extracted elements saved to {output_file}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else None
        process_file(input_file, output_file)
    else:
        print("Usage: python extract_pentaho.py input_file.ktr [output_file]")
        print("Note: If output_file is not specified, input_file_extracted.xml will be used")